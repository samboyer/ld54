class_name RoomManager
extends Node


var current_room:Node2D = null
var next_room:Node2D = null

@export
var ROOM_TRANSITION_TIME_SECS:= 0.5
@export
var SCREEN_HEIGHT:= 600

@export
var ROOM_PREFAB:PackedScene=null

@export
var bm:BeesManager=null

var rooms_reached := 0

func load_next_room():
    var new_room:=ROOM_PREFAB.instantiate()
    # @@@ Apply room variations here
    new_room.position = Vector2(0, SCREEN_HEIGHT)
    add_child(new_room)
    next_room = new_room
    rooms_reached+=1
    print("ROOM ",rooms_reached)

var room_transitioning:=false
var room_transition_t:float=0

func start_transition_to_next_room():
    room_transitioning=true
    room_transition_t=0
    bm.visible=false

func finish_transition_to_next_room():
    room_transitioning=false
    room_transition_t=0
    next_room.position = Vector2(0,0)
    if current_room:
        current_room.queue_free()
    current_room=next_room
    next_room=null
    for b in get_tree().get_nodes_in_group("bees"):
        b.position = Vector2(0,SCREEN_HEIGHT/2-16)
    bm.visible=true


func _process(delta):
    if room_transitioning:
        room_transition_t+=delta/ROOM_TRANSITION_TIME_SECS
        # apply room movement
        var t := Util.cubic_ease_out(room_transition_t)
        if current_room!=null:
            current_room.position = Vector2(0,SCREEN_HEIGHT*t)
        next_room.position = Vector2(0,SCREEN_HEIGHT*(t-1))
        if room_transition_t>=1:
            finish_transition_to_next_room()

func make_and_transition_to_room():
    load_next_room()
    start_transition_to_next_room()

func _ready():
    load_next_room()
    finish_transition_to_next_room() # skip transition
