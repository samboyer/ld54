class_name Room_Door
extends Node2D

@export
var DOWN_MOVE:float=108
@export
var DOOR_OPEN_TIME_SECS:float=1.0

@export
var DOOR_MOVE_CAMERA_SHAKE:float=25
@export
var DOOR_FINISH_CAMERA_SHAKE:float=50

@export
var door_rumble_sfx:AudioStreamPlayer=null
@export
var door_slam_sfx:AudioStreamPlayer=null

@export
var should_auto_open:=false
@export
var auto_open_time:=3.0


var start_pos:float=0
var door_opening:=false
var door_opened:=false
var door_anim_t:=0.0

var camera=null
var rm:RoomManager = null;

var alive_time :=0.0

func _ready():
	camera = get_tree().get_first_node_in_group("cameras")
	rm = get_tree().get_first_node_in_group('RoomManager')

func start_door_open():
	if door_opening or door_opened:
		return
	door_opening=true
	door_anim_t=0
	start_pos = position.y
	door_rumble_sfx.play()

func end_door_open():
	door_opened = true
	door_opening=false
	door_anim_t=0
	camera.jitter(DOOR_FINISH_CAMERA_SHAKE)
	door_rumble_sfx.stop()
	door_slam_sfx.play()
	if bees_in_area:
		rm.make_and_transition_to_room()
		door_opened = false

func _process(delta):
	if door_opening:
		door_anim_t+=delta/DOOR_OPEN_TIME_SECS
		# apply room movement
		var t := Util.cubic_ease_out(door_anim_t)
		position.y = start_pos + DOWN_MOVE * t
		camera.jitter(DOOR_MOVE_CAMERA_SHAKE)
		if door_anim_t>=1:
			end_door_open()
	alive_time+=delta
	if should_auto_open and alive_time>auto_open_time:
		start_door_open()

# func _input(event):
#     if (event is InputEventMouseButton
#         and event.pressed):
#         start_door_open()

var bees_in_area:=false
func _on_next_level_area_area_entered(area):
	bees_in_area = true
	if door_opened:
		rm.make_and_transition_to_room()
		door_opened = false


func _on_next_level_area_area_exited(area):
	bees_in_area = false
