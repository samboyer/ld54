extends Camera2D

var camera_shake: float = 0.0
var camera_shake_dropoff: float = 1000.0

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func jitter(amount: float):
    camera_shake = amount

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    camera_shake = max(camera_shake - camera_shake_dropoff * delta, 0.0)
    position = Vector2(Util.rand_range_float(-camera_shake, camera_shake), Util.rand_range_float(-camera_shake, camera_shake))
