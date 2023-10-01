class_name Powerup
extends Area2D

enum PowerupType { Speed, Power, Auto, Invuln }
var powerup_type: PowerupType

var collected: bool = false
var _collected_countdown: float = 1.0

var bm: BeesManager

# Called when the node enters the scene tree for the first time.
func _ready():
    bm = get_tree().get_first_node_in_group('BeesManager')

    match Util.rand_range(0, 4):
        0:
            powerup_type = PowerupType.Speed
            $Sprite2D.texture = load("res://Textures/powerup-0.png")
        1:
            powerup_type = PowerupType.Power
            $Sprite2D.texture = load("res://Textures/powerup-1.png")
        2:
            powerup_type = PowerupType.Auto
            $Sprite2D.texture = load("res://Textures/powerup-2.png")
        3:
            powerup_type = PowerupType.Invuln
            $Sprite2D.texture = load("res://Textures/powerup-3.png")

func _process(delta: float):
    if collected:
        _collected_countdown -= delta
        $Sprite2D.modulate.a = 0#_collected_countdown ** 2
        if _collected_countdown <= 0:
            queue_free()

func _on_area_entered(_area: Area2D):
    if not collected:
        bm.powerup(powerup_type)
        collected = true
