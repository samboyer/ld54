class_name BeatMatchTest
extends Node2D

@export var TEMPO:=128.0
@export var cam:Camera2D=null
@export var other_stuff_to_zoom:Array[Node2D]=[]


@export var max_cam_zoom = 1.4
@export var max_other_zoom = 0.9

var source:AudioStreamPlayer=null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var secs_per_beat := 60.0 / TEMPO
	var progress_through_beat :float= fmod(source.get_playback_position(), secs_per_beat) / secs_per_beat

	var cz:=Util.cubic_ease_out(lerp(max_cam_zoom, 1.0, progress_through_beat))
	var oz:=Util.cubic_ease_out(lerp(max_other_zoom, 1.0, progress_through_beat))

	cam.zoom = Vector2(cz, cz)
	for stuff in other_stuff_to_zoom:
		stuff.scale = Vector2(oz, oz)
