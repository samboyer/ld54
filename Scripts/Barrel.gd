class_name Barrel
extends Targetable

@export var contents: PackedScene = null

@onready var powerup = preload("res://Objects/Powerup.tscn")

func _ready():
    super()

func on_death():
    $Sprite2D.visible = false
    $Particles.emitting = true

    var powerup_instance = powerup.instantiate()
    powerup_instance.position = position
    get_parent().add_child(powerup_instance)
