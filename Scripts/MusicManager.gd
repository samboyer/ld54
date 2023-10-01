class_name MusicManager
extends Node2D

# Choose from one of these layers first, then choose from either
@export
var initial_music_layers:Array[AudioStream] = []

@export
var latter_music_layers:Array[AudioStream] = []

var music_players:Array[AudioStreamPlayer] = []

var currently_playing_layers:int = 0

@export var beat_match_effect:BeatMatchTest = null

var enabled_layers:Array[bool] = []
var total_layers :=0

@export var open_hat_idx:=7

# Called when the node enters the scene tree for the first time.
func _ready():
    var filter:AudioEffectLowPassFilter = AudioServer.get_bus_effect(1,0)
    filter.cutoff_hz = 20000
    total_layers = len(initial_music_layers)+len(latter_music_layers)

    for layer in initial_music_layers+latter_music_layers:
        var player := AudioStreamPlayer.new()
        player.stream = layer
        add_child(player)
        player.volume_db = -80
        player.play()
        player.bus = 'music'
        music_players.append(player)
        enabled_layers.append(false)

    # choose a random initial layer
    var initial_layer = Util.rand_range(0,len(initial_music_layers))
    enabled_layers[initial_layer] = true
    music_players[initial_layer].volume_db = 0.0
    currently_playing_layers = 1

    beat_match_effect.source = music_players[0]

func enable_next_layer():
    if currently_playing_layers < total_layers:
        var next_layer:int
        # if we've got to room 5 and the kick hasn't come in, bring that in
        if currently_playing_layers ==4 and not enabled_layers[0]:
            next_layer = 0
        elif !enabled_layers[open_hat_idx]:
            next_layer = open_hat_idx
        else:
            # pick randomly from remaining layers
            next_layer = Util.rand_range(0,len(music_players))
            while enabled_layers[next_layer]:
                next_layer = (next_layer+1) % total_layers

        music_players[next_layer].volume_db = 0.0
        currently_playing_layers+=1
    else:
        print("No more music layers to play")


func stop_all():
    # for player in music_players:
    #     player.stop()
    var filter:AudioEffectLowPassFilter = AudioServer.get_bus_effect(1,0)
    filter.cutoff_hz = 2000
