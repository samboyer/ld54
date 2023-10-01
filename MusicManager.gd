class_name MusicManager
extends Node2D

@export
var music_layers:Array[AudioStream] = []

var music_players:Array[AudioStreamPlayer] = []

var currently_playing_layers:int = 0

@export var beat_match_effect:BeatMatchTest = null

# Called when the node enters the scene tree for the first time.
func _ready():
	for layer in music_layers:
		var player := AudioStreamPlayer.new()
		player.stream = layer
		add_child(player)
		player.volume_db = -80
		player.play()
		player.bus = 'music'
		music_players.append(player)
	enable_next_layer()
	beat_match_effect.source = music_players[0]

func enable_next_layer():
	if currently_playing_layers < len(music_layers):
		music_players[currently_playing_layers].volume_db = 0.0
		currently_playing_layers+=1
	else:
		print("No more music layers to play")


func stop_all():
	# for player in music_players:
	# 	player.stop()
	var filter:AudioEffectLowPassFilter = AudioServer.get_bus_effect(1,0)
	filter.cutoff_hz = 2000
