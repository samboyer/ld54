class_name Bee
extends CharacterBody2D


var maxspeed := 1000
var accel := 8000
var jitter: int = 50

@export var attack_cooldown: float = 5.0
var attacking: bool = false
var _attack_cooldown_counter: float = 0.0

@export var base_damage: int = 5

var particles: Node

var damageCounterObj = preload("res://Objects/DamageCounter.tscn")
var beeGhostObj = preload("res://Objects/BeeGhost.tscn")

var bm:BeesManager = null;

func _ready():
	self.add_to_group("bees")
	particles = get_node("Particles")
	bm = get_tree().get_first_node_in_group('BeesManager')

# Called when the bee is killed
func kill():
	# TODO: spawn ghost, play death animation, etc
	var beeGhost = beeGhostObj.instantiate()
	beeGhost.initial_position = position
	get_parent().add_child(beeGhost)
	bm.num_bees-=1
	queue_free()

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
	velocity = dir * 10000

	var damage = base_damage

	target.damage(damage)

	var damageCounter = damageCounterObj.instantiate()
	damageCounter.position = target.position + Vector2(Util.rand_range(-25, 25), Util.rand_range(-25, 25))
	damageCounter.amount = damage
	get_parent().add_child(damageCounter)

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
	var jitter_vector := Vector2(Util.rand_range(-jitter, jitter), Util.rand_range(-jitter, jitter))
	var dir := (mouse_pos - self.position + jitter_vector).normalized() * accel
	velocity += dir * delta
	velocity = velocity.limit_length(maxspeed)
	move_and_slide()
