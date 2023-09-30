extends CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


var vel:=Vector2(0,0)
var maxspeed:=1000
var accel:=10000

var jitter:int=100

func rand_range(min,max):
	return randi()%(max-min)+min

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var mouse_pos:Vector2= self.get_parent().get_local_mouse_position()
	var dir = (mouse_pos - self.position).normalized() * accel
	vel+=dir * delta
	vel+=Vector2(rand_range(-jitter,jitter),rand_range(-jitter,jitter))
	vel = vel.limit_length(maxspeed)
	self.velocity=vel
	move_and_slide()
