extends Node2D

@export
var DOWN_MOVE:float=108
@export
var DOOR_OPEN_TIME_SECS:float=1.0

@export
var DOOR_MOVE_CAMERA_SHAKE:float=25
@export
var DOOR_FINISH_CAMERA_SHAKE:float=50


var start_pos:float=0
var door_opening:=false
var door_opened:=false
var door_anim_t:=0.0

var camera=null

func _ready():
	camera = get_tree().get_first_node_in_group("cameras")

func start_door_open():
	if door_opened:
		return
	door_opened = true
	door_opening=true
	door_anim_t=0
	start_pos = position.y

func end_door_open():
	door_opening=false
	door_anim_t=0
	camera.jitter(DOOR_FINISH_CAMERA_SHAKE)

func _process(delta):
	if door_opening:
		door_anim_t+=delta/DOOR_OPEN_TIME_SECS
		# apply room movement
		var t := Util.cubic_ease_out(door_anim_t)
		position.y = start_pos + DOWN_MOVE * t
		camera.jitter(DOOR_MOVE_CAMERA_SHAKE)
		if door_anim_t>=1:
			end_door_open()

func _input(event):
	if (event is InputEventMouseButton
		and event.pressed):
		start_door_open()
