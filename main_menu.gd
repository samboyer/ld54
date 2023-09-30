extends Node2D

@export
var main_scene:PackedScene = null

func _start_button_pressed():
    get_tree().change_scene_to_packed(main_scene)