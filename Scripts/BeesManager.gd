class_name BeesManager
extends Node2D

@onready
var beeObj = preload("res://Objects/bee.tscn")

@export
var NUM_BEES: int = 100

var SHOOT_PULL_INWARD: float = 0.5

var bees: Array = []

@export var attack_cooldown: float = 0.05
@export var attack_bees: int = 1
@export var attack_jitter: float = 100.0
var _attacking: bool = false
var _attack_cooldown_counter: float = 0.0

@export var camera: Camera2D

var reticule: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
    for i in range(NUM_BEES):
        var x = beeObj.instantiate()
        add_child(x)
        x.position = Vector2(randi() % 500 - 250, randi() % 500 - 250)
        bees.append(x)

    reticule = find_child("Reticule")

var centre_of_mass:Vector2 = Vector2.ZERO

func _input(event):
    if event.is_action_pressed("attack"):
        _attack_cooldown_counter = 0.0
        _attacking = true
    elif event.is_action_released("attack"):
        _attacking = false

func find_target() -> Targetable:
    var target: Targetable = null
    var target_distance: float = 10000
    var mouse_position: Vector2 = get_global_mouse_position()
    for node in get_tree().get_nodes_in_group("targetable"):
        if node.targetable and node.global_position.distance_to(mouse_position) < target_distance:
            target = node
            target_distance = node.global_position.distance_to(mouse_position)
    return target

func find_free_bee() -> Bee:
    for b in bees:
        if not b.attacking:
            return b
    return null


func fire_a_bee():
    var fired_bee: Bee = find_free_bee()
    if fired_bee != null:
        fired_bee.attack(reticule.target)
        camera.jitter(attack_jitter)
        _attack_cooldown_counter = attack_cooldown
        for b in bees:
            if b != fired_bee:
                b.position = lerp(b.position, centre_of_mass, SHOOT_PULL_INWARD)
                # b.velocity = (centre_of_mass - b.position).normalized() * 100.0

# # Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    reticule.target = find_target()

    _attack_cooldown_counter = max(_attack_cooldown_counter - delta, 0.0)
    if _attacking and _attack_cooldown_counter <= 0:
        for _i in range(attack_bees):
            fire_a_bee()

    centre_of_mass = Vector2.ZERO
    for b in bees:
        centre_of_mass += b.position
    centre_of_mass /= NUM_BEES
    queue_redraw()

# func _draw():
#     draw_circle(centre_of_mass, 10, Color(1, 0, 0))
