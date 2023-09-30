class_name Bee
extends CharacterBody2D


var vel := Vector2(0,0)
var maxspeed := 1000
var accel := 10000

var jitter: int = 100

@export var attack_cooldown: float = 5.0
var attacking: bool = false
var _attack_cooldown_counter: float = 0.0

@export var base_damage: int = 5

var particles: Node

func _ready():
    particles = get_node("Particles")
    print(particles)

func attack(target: Targetable):
    attacking = true
    var dir: Vector2 = (target.position - position).normalized()
    var centre: Vector2 = (position - target.position) / 2
    var extent: float = (target.position - position).length() / 2

    particles.position = centre
    particles.emission_rect_extents = Vector2(extent, 0)
    particles.rotation = dir.angle()

    particles.emitting = true

    _attack_cooldown_counter = attack_cooldown
    position = target.position
    vel = dir * 10000

    target.damage(base_damage)

func _process(delta):
    if attacking:
        _attack_cooldown_counter -= delta
        if _attack_cooldown_counter <= 0.0:
            attacking = false
            particles.emitting = false
            _attack_cooldown_counter = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
    var mouse_pos: Vector2 = self.get_parent().get_local_mouse_position()
    var dir = (mouse_pos - self.position).normalized() * accel
    vel += dir * delta
    vel += Vector2(Util.rand_range(-jitter, jitter), Util.rand_range(-jitter, jitter))
    vel = vel.limit_length(maxspeed)
    velocity = vel
    move_and_slide()
