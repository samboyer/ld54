class_name Enemy
extends Targetable

@export var move_speed: float = 150
@export var charge_time: float = 0.6
@export var charge_speed: float = 0.3
@export var cooldown_time: float = 2.0
@export var jitter: float = 0.5
enum EnemyType { BASE, SHY, STRAFE }
@export var enemy_type: EnemyType = EnemyType.BASE

@export_group("Sprites")
@export var sprite_base: Texture2D
@export var sprite_shy: Texture2D
@export var sprite_strafe: Texture2D

var _state: int = 0
var _state_cooldown: float = 0.0
var _direction: Vector2 = Vector2(0, 0)

var bm: BeesManager

func _ready():
    choose_target()
    _state = 2
    _state_cooldown = charge_time + Util.rand_range_float(-jitter / 2, jitter / 2)
    bm = get_tree().get_first_node_in_group('BeesManager')

    match enemy_type:
        EnemyType.BASE:
            $Sprite2D.texture = sprite_base
        EnemyType.SHY:
            $Sprite2D.texture = sprite_shy
        EnemyType.STRAFE:
            $Sprite2D.texture = sprite_strafe

    super()

func on_death():
    $Sprite2D.visible = false
    $Particles.emitting = true

func choose_target():
    _direction = (get_global_mouse_position() - global_position).normalized()
    match enemy_type:
        EnemyType.BASE:
            pass
        EnemyType.SHY:
            _direction *= -1
        EnemyType.STRAFE:
            _direction = _direction.rotated(0.5 * PI)


func _process(delta):
    if not dead:
        _state_cooldown -= delta
        if _state_cooldown <= 0:
            match _state:
                0:
                    velocity = _direction * move_speed
                    _state = 1
                    _state_cooldown = cooldown_time + Util.rand_range_float(-jitter / 2, jitter / 2)
                1:
                    _state = 2
                    _state_cooldown = 0.0
                2:
                    _state = 0
                    _state_cooldown = charge_time + Util.rand_range_float(-jitter / 2, jitter / 2)
        match _state:
            0:
                choose_target()
                velocity = _direction * move_speed * charge_speed * -1
            1:
                var acceleration = velocity * -1
                velocity += acceleration * delta
            2:
                velocity = Vector2.ZERO

        #position += velocity * delta
        move_and_slide()

    super(delta)


func _on_area_2d_body_entered(body: Node2D):
    if body is Bee and not bm.invulnerable:
        body.kill()
        bm.damage()
