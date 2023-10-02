class_name AcidBeeSwarm
extends Node2D

@onready
var acidBeeObj = preload("res://Objects/AcidBee.tscn")

@export var key_to_drop: PackedScene

@export var STARTING_NUM_BEES: int = 25
@export var health: int = 50
@export var speed: float = 50
@export var powerup_chance: float = 0.2
var num_bees: int
var starting_health: int
var centre: Node2D

var death_cooldown: float = 1.0
var dead: bool = false

@onready var powerup = preload("res://Objects/Powerup.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
    num_bees = STARTING_NUM_BEES
    centre = self.get_node("Centre")
    centre.position = position
    position = Vector2.ZERO
    centre.health = health
    starting_health = health
    for i in range(STARTING_NUM_BEES):
        var x = acidBeeObj.instantiate()
        x.target = centre
        add_child(x)
        x.position = Vector2(Util.rand_range(-100, 100), Util.rand_range(-100, 100))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if dead:
        death_cooldown -= delta
        if death_cooldown <= 0:
            queue_free()
    else:
        # move centre towards player
        var dir = (get_global_mouse_position() - centre.position).normalized()
        centre.position += dir * speed * delta

func damage(amount: int):
    health -= amount
    if health <= 0:
        dead = true
        on_death()

    # kill bees down to health
    var target_bees = float(health) / float(starting_health) * STARTING_NUM_BEES
    if target_bees < num_bees:
        var to_kill = num_bees - target_bees
        for node in get_children():
            if to_kill <= 0:
                break
            if node is AcidBee:
                node.kill()
                to_kill -= 1
                num_bees -= 1

    if num_bees <= 0:
        dead = true
        on_death()

func on_death():
    for node in get_children():
        if node is AcidBee:
            node.kill()
    $EnemyDeathSFX.play()

    # if all other enemies are dead, spawn a key at this position
    var all_dead := true
    for e in get_tree().get_nodes_in_group('enemy'):
        all_dead = all_dead and e.dead
    if all_dead:
        var key := key_to_drop.instantiate()
        key.position = centre.position
        get_parent().add_child(key)

    if Util.rand_range_float(0,1) < powerup_chance:
        var powerup_instance = powerup.instantiate()
        powerup_instance.position = centre.position
        get_parent().add_child(powerup_instance)