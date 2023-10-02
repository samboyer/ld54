extends Node2D

@export
var main_scene:PackedScene = null

@export var is_main_menu: bool = false

var audio_countdown: float = 0.3
var audio_playing: bool = false

var intro_countdown: float = 0.8
var intro_playing: bool = false

var play_button_countdown = 5.8
var play_button_ready = false

func _ready():
    if is_main_menu:
        get_node("Logo/Sprite2D").visible = false
        get_node("Logo/Sprite2D2").visible = false
        get_node("CanvasLayer").visible = false


func _process(delta):
    if is_main_menu:
        audio_countdown = max(0, audio_countdown - delta)
        if audio_countdown <= 0 and !audio_playing:
            audio_playing = true
            get_node("AudioStreamPlayer").play()

        intro_countdown = max(0, intro_countdown - delta)
        if intro_countdown <= 0 and !intro_playing:
            intro_playing = true
            get_node("Logo/AnimationPlayer").play("logo_animation")
            get_node("Logo/Sprite2D").visible = true
            get_node("Logo/Sprite2D2").visible = true

        play_button_countdown = max(0, play_button_countdown - delta)
        if play_button_countdown <= 0 and !play_button_ready:
            play_button_ready = true
            $CanvasLayer.visible = true

func _start_button_pressed():
    get_tree().change_scene_to_packed(main_scene)

func _reload_scene():
    get_tree().reload_current_scene()
