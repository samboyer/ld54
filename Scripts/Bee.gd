class_name Bee
extends CharacterBody2D


var maxspeed := 1000
var accel := 8000
var jitter: int = 50

@export var attack_cooldown: float = 1
var attacking: bool = false
var _attack_cooldown_counter: float = 0.0

@export var base_damage: float = 5.0
@export var damage_spread: float = 0.5
@export var base_crit: float = 0.1
@export var crit_multiplier: float = 3.0
var damage: float
var crit: float

var particles: Node

var damageCounterObj = preload("res://Objects/DamageCounter.tscn")
var beeGhostObj = preload("res://Objects/BeeGhost.tscn")

var bm:BeesManager = null;

func _ready():
    self.add_to_group("bees")
    particles = get_node("Particles")
    bm = get_tree().get_first_node_in_group('BeesManager')
    print(bm)

    damage = base_damage
    crit = base_crit

# Called when the bee is killed
# Override is used if the bee should die even if attacking
func kill(override: bool = false):
    var rm:RoomManager = get_tree().get_first_node_in_group('RoomManager')
    if rm.room_transitioning:
        return
    if not attacking or override:
        for child in get_children():
            if child is Key:
                child.key_picked_up = false
                remove_child(child)
                get_parent().get_parent().add_child(child)
                child.position = position

        var beeGhost = beeGhostObj.instantiate()
        beeGhost.initial_position = position
        get_parent().add_child(beeGhost)
        bm.num_bees-=1
        queue_free()

func attack(target: Targetable) -> float:
    var target_position:Vector2
    if target == null:
        # choose a random direction
        target_position = bm.centre_of_mass + Vector2.from_angle(Util.rand_range_float(0, 2 * 3.141)) * 100
    else:
        target_position = target.position
    attacking = true
    var dir: Vector2 = (target_position - position).normalized()
    var centre: Vector2 = (position - target_position) / 2
    var extent: float = (target_position - position).length() / 2

    particles.position = centre
    particles.emission_rect_extents = Vector2(extent, 0)
    particles.rotation = dir.angle()

    particles.emitting = true
    particles.restart()

    _attack_cooldown_counter = attack_cooldown

    position = target_position

    velocity = dir * 10000

    var damage_amount := damage * Util.rand_range_float(1 - (damage_spread / 2), 1 + (damage_spread / 2))
    var crit_roll := Util.rand_range_float(0, 1) < crit
    if crit_roll:
        damage_amount *= crit_multiplier

    if target != null:
        target.damage(int(damage_amount), self)

        var damageCounter = damageCounterObj.instantiate()
        damageCounter.position = target.position + Vector2(Util.rand_range(-25, 25), Util.rand_range(-25, 25))
        damageCounter.amount = int(damage_amount)
        get_parent().add_child(damageCounter)

        return crit_roll
    else:
        return 0.0


func _process(delta):
    if attacking:
        _attack_cooldown_counter -= delta
        if _attack_cooldown_counter <= 0.0:
            attacking = false
            particles.emitting = false
            _attack_cooldown_counter = 0.0

var freeze_time := 0.0;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
    if freeze_time>0:
        freeze_time-=delta
    else:
        var mouse_pos: Vector2 = self.get_parent().get_local_mouse_position()
        var jitter_vector := Vector2(Util.rand_range(-jitter, jitter), Util.rand_range(-jitter, jitter))
        var dir := (mouse_pos - self.position + jitter_vector).normalized() * accel
        velocity += dir * delta
    var damping := velocity * -3
    velocity += damping * delta
    velocity = velocity.limit_length(maxspeed)
    move_and_slide()
    $Sprite2d.flip_h = velocity.x < 0
