extends Area2D

enum PowerupType { Speed, Power, Auto }
var powerup_type: PowerupType

# Called when the node enters the scene tree for the first time.
func _ready():
    match Util.rand_range(0, 3):
        0:
            powerup_type = PowerupType.Speed
            $Sprite2D.texture = load("res://Textures/powerup-0.png")
        1:
            powerup_type = PowerupType.Power
            $Sprite2D.texture = load("res://Textures/powerup-1.png")
        2:
            powerup_type = PowerupType.Auto
            $Sprite2D.texture = load("res://Textures/powerup-2.png")