extends Node2D

@export var speed: float = 30
@export var rotate_speed: float = 100
@export var scale_speed: float = 4

var target: Targetable = null

var outer: Sprite2D
var inner: Sprite2D

var t: float = 0

func _ready():
    visible = true

    outer = get_node("ReticuleOuter")
    inner = get_node("ReticuleInner")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if target != null:
        position = position.lerp(target.global_position, delta * speed)

    outer.rotation_degrees += delta * rotate_speed
    inner.rotation_degrees -= delta * rotate_speed

    t += delta
    scale = Vector2.ONE * (0.2 * sin(t * scale_speed) + 1.2)
