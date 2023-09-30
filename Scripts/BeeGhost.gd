extends Node2D

var max_lifetime: float = 2.0
var life: float = 0
var initial_position: Vector2
var _start: float

func _ready():
    life = 0.0
    position = initial_position
    _start = Util.rand_range_float(0.0, PI * 2.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    life += delta
    if life > max_lifetime:
        queue_free()

    position = initial_position + Vector2((sin(life * 3 + _start) - sin(_start)) * 30, -life * 100)
    modulate.a = 1.0 - life / max_lifetime
