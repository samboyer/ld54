extends Node2D

@export var speed: float = 30
@export var rotate_speed: float = 100
@export var scale_speed: float = 4

@export var sprite_active: Texture2D
@export var sprite_inactive: Texture2D

var target: Targetable = null

var outer: Sprite2D
var inner: Sprite2D

var active: bool = true:
    get:
        return active
    set(value):
        active = value
        if active:
            if outer != null and inner != null:
                outer.texture = sprite_active
                inner.texture = sprite_active
        else:
            if outer != null and inner != null:
                outer.texture = sprite_inactive
                inner.texture = sprite_inactive

var t: float = 0

func _ready():
    visible = true

    outer = get_node("ReticuleOuter")
    inner = get_node("ReticuleInner")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if target != null:
        visible = true
        position = position.lerp(target.global_position, delta * speed)
    else:
        visible = false

    if active:
        outer.rotation_degrees += delta * rotate_speed
        inner.rotation_degrees -= delta * rotate_speed

        t += delta
        scale = Vector2.ONE * (0.2 * sin(t * scale_speed) + 1.2)
