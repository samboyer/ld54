class_name BeesManager
extends Node2D

@onready
var beeObj = preload("res://Objects/bee.tscn")

@export
var NUM_BEES: int = 100

var bees: Array = []

@export var attack_cooldown: float = 0.05
@export var attack_bees: int = 1
@export var attack_jitter: float = 100.0
var _attacking: bool = false
var _attack_cooldown_counter: float = 0.0

@export var camera: Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
    for i in range(NUM_BEES):
        var x = beeObj.instantiate()
        add_child(x)
        x.position = Vector2(randi() % 500 - 250, randi() % 500 - 250)
        bees.append(x)

var centre_of_mass:Vector2 = Vector2.ZERO

func _input(event):
    if event.is_action_pressed("attack"):
        _attacking = true
    elif event.is_action_released("attack"):
        _attacking = false

func find_target() -> Vector2:
    return Vector2.ZERO # TODO

func find_free_bee() -> Bee:
    for b in bees:
        if not b.attacking:
            return b
    return null

# # Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    _attack_cooldown_counter = max(_attack_cooldown_counter - delta, 0.0)
    if _attacking and _attack_cooldown_counter <= 0:
        var target: Vector2 = find_target()
        for _i in range(attack_bees):
            var bee: Bee = find_free_bee()
            if bee != null:
                bee.attack(target)
                camera.jitter(attack_jitter)
                _attack_cooldown_counter = attack_cooldown

    centre_of_mass = Vector2.ZERO
    for b in bees:
        centre_of_mass += b.position
    centre_of_mass /= NUM_BEES
    queue_redraw()

func _draw():
    draw_circle(centre_of_mass, 10, Color(1, 0, 0))
