class_name Enemy
extends Targetable

@export var key_to_drop: PackedScene
@export var move_speed: float = 150
@export var charge_time: float = 0.6
@export var charge_speed: float = 0.3
@export var cooldown_time: float = 2.0
@export var jitter: float = 0.5
enum EnemyType { BASE, SHY, STRAFE, STILL, GO_FAST }
@export var enemy_type: EnemyType = EnemyType.BASE

@export_group("Gun")
@export var gun: bool = false
@export var gun_speed: float = 100
@export var gun_cooldown: float = 0.5

@export_group("Electricity")
@export var electricity: bool = false
@export var electricity_time: float = 3.0
@export var electricity_cooldown: float = 5.0

@export_group("Sprites")
@export var sprite_base: Texture2D
@export var sprite_shy: Texture2D
@export var sprite_strafe: Texture2D
@export var sprite_still: Texture2D
@export var sprite_go_fast: Texture2D


var _state: int = 0
var _state_cooldown: float = 0.0
var _direction: Vector2 = Vector2(0, 0)

var _gun_cooldown: float = 0.0
var electricity_on: bool = false
var _electricity_cooldown: float = 0.0

@onready var bulletObj = preload("res://Objects/Bullet.tscn")

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
        EnemyType.STILL:
            $Sprite2D.texture = sprite_still
        EnemyType.GO_FAST:
            $Sprite2D.texture = sprite_go_fast

    $Gun.visible = gun
    _gun_cooldown = gun_cooldown

    super()

var im_dead :=false

func on_death():
    im_dead = true
    Util.num_enemies_killed +=1
    $Sprite2D.visible = false
    $Gun.visible = false
    $Particles.emitting = true
    $CollisionShape2D.disabled = true

    # if all other enemies are dead, spawn a key at this position
    var all_dead := true
    for e in get_tree().get_nodes_in_group('enemy'):
        all_dead = all_dead and e.im_dead
    if all_dead:
        var key:=key_to_drop.instantiate()
        key.position = position
        get_parent().add_child(key)



func choose_target():
    _direction = (get_global_mouse_position() - global_position).normalized()
    match enemy_type:
        EnemyType.BASE:
            pass
        EnemyType.SHY:
            _direction *= -1
        EnemyType.STRAFE:
            _direction = _direction.rotated(0.5 * PI)
        EnemyType.STILL:
            _direction = Vector2.ZERO
        EnemyType.GO_FAST:
            pass

func _process(delta):
    if not dead:
        if enemy_type == EnemyType.GO_FAST:
            choose_target()
            velocity += _direction * move_speed * delta
            velocity -= velocity * 0.5 * delta
        else:
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

        if velocity.x < 0:
            $Sprite2D.flip_h = true
            $Gun.flip_h = true
            $Gun.position.x = -16
        elif velocity.x > 0:
            $Sprite2D.flip_h = false
            $Gun.flip_h = false
            $Gun.position.x = 16

        if gun:
            _gun_cooldown -= delta
            var dir = (bm.centre_of_mass - global_position).normalized()
            if _gun_cooldown <= 0:
                _gun_cooldown = gun_cooldown
                var bullet = bulletObj.instantiate()
                bullet.position = $Gun.global_position
                bullet.direction = dir
                bullet.speed = gun_speed
                get_parent().add_child(bullet)

        if electricity:
            _electricity_cooldown -= delta
            if _electricity_cooldown <= 0:
                if electricity_on:
                    electricity_on = false
                    _electricity_cooldown = electricity_cooldown
                else:
                    electricity_on = true
                    _electricity_cooldown = electricity_time
                    position+=Vector2(Util.rand_range_float(-10,10),Util.rand_range_float(-10,10))
                $ParticlesElectricity.emitting = electricity_on

        #position += velocity * delta
        move_and_slide()

    super(delta)

func damage(amount: int, source: Bee):
    if electricity_on:
        source.kill(true)

    super(amount, source)


func _on_area_2d_body_entered(body: Node2D):
    if body is Bee and not bm.invulnerable and not dead:
        body.kill()
        bm.damage()
