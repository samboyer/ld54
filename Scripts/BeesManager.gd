class_name BeesManager
extends Node2D

@onready
var beeObj = preload("res://Objects/bee.tscn")

@export
var NUM_BEES:int = 100

var bees:Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
    for i in range(NUM_BEES):
        var x = beeObj.instantiate()
        add_child(x)
        x.position = Vector2(randi() % 1000 - 500, randi() % 1000 - 500)
        bees.append(x)

var centre_of_mass:Vector2 = Vector2.ZERO

# # Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    centre_of_mass = Vector2.ZERO
    for b in bees:
        centre_of_mass += b.position
    centre_of_mass /= NUM_BEES
    queue_redraw()

func _draw():
    draw_circle(centre_of_mass, 10, Color(1, 0, 0))
