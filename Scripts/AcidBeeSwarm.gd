class_name AcidBeeSwarm
extends Node2D

@onready
var acidBeeObj = preload("res://Objects/AcidBee.tscn")

@export var STARTING_NUM_BEES: int = 25
@export var health: int = 50
@export var speed: float = 50
var num_bees: int
var starting_health: int
var centre: Node2D

var death_cooldown: float = 1.0
var dead: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
    num_bees = STARTING_NUM_BEES
    centre = self.get_node("Centre")
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