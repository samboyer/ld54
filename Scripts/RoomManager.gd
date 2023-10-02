class_name RoomManager
extends Node


var current_room:Node2D = null
var next_room:Node2D = null

@export
var ROOM_TRANSITION_TIME_SECS:= 0.5
@export
var TEXT_STAY_ON_TIME:= 2.0
@export
var SCREEN_HEIGHT:= 600

@export
var room_starting:PackedScene=null
@export
var room_tutorials:Array[PackedScene]=[]

@export
var room_main:PackedScene=null

@export
var enemy_objects:Array[PackedScene]=[]
@export
var enemy_object_hardnesses:Array[int]=[]
@export
var enemy_object_weights:Array[int]=[]
var enemy_object_total_weight: int = 0
@export
var neutral_room_objects:Array[PackedScene]=[]

@export var enemy_health_base: int = 40

@export
var max_neutral_objects_per_room:int=2
@export
var hardness_per_room:int=4 #how much 'total hardness' goes up per room
@export
var all_one_enemy_room_chance: float = 0.3
@export
var max_enemies_per_room: int = 20
var last_room_pity_room: bool = true

@export
var room_num_label:Label=null
@export
var room_swoosh_sfx:AudioStreamPlayer=null
@export
var bm:BeesManager=null
@export
var mm:MusicManager=null

var cm:CanvasModulate=null
var current_color = Color(1,1,1,1)
var next_color = Color(1,1,1,1)

var rooms_reached := -1

var roman_numerals =["I","II","III","IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX", "XXI", "XXII", "XXIII", "XXIV", "XXV", "XXVI", "XXVII", "XXVIII", "XXIX", "XXX", "XXXI", "XXXII", "XXXIII", "XXXIV", "XXXV", "XXXVI", "XXXVII", "XXXVIII", "XXXIX", "XL", "XLI", "XLII", "XLIII", "XLIV", "XLV", "XLVI", "XLVII", "XLVIII", "XLIX", "L", "LI", "LII", "LIII", "LIV", "LV", "LVI", "LVII", "LVIII", "LIX", "LX", "LXI", "LXII", "LXIII", "LXIV", "LXV", "LXVI", "LXVII", "LXVIII", "LXIX", "LXX", "LXXI", "LXXII", "LXXIII", "LXXIV", "LXXV", "LXXVI", "LXXVII", "LXXVIII", "LXXIX", "LXXX", "LXXXI", "LXXXII", "LXXXIII", "LXXXIV", "LXXXV", "LXXXVI", "LXXXVII", "LXXXVIII", "LXXXIX", "XC", "XCI", "XCII", "XCIII", "XCIV", "XCV", "XCVI", "XCVII", "XCVIII", "XCIX", "C"]

func load_next_room():
    var new_room = null
    if rooms_reached == -1:
        new_room=room_starting.instantiate()
    else:
        new_room=room_main.instantiate()

    if rooms_reached >= 1:
        populate_room(new_room)
    elif rooms_reached == 0:
        var obj = enemy_objects[0].instantiate()
        obj.health = enemy_health_base
        obj.position = Vector2(Util.rand_range_float(-350,350), Util.rand_range_float(-20,280))
        new_room.add_child(obj)

    next_room = new_room
    new_room.position = Vector2(0, SCREEN_HEIGHT)
    add_child(new_room)
    rooms_reached+=1
    print("ROOM ",rooms_reached)



func populate_room(new_room:Node):
    var hive_pity_roll = Util.rand_range_float(0, 1) > max((float(bm.num_bees) / (float(bm.STARTING_NUM_BEES) * 0.6)), 0.4)
    hive_pity_roll = hive_pity_roll and not last_room_pity_room
    last_room_pity_room = hive_pity_roll

    # neutral objects
    var num_neutral := 0
    if Util.rand_range_float(0, 1) < 0.2:
        num_neutral += 1
    for i in range(num_neutral):
        var j = Util.rand_range(1, len(neutral_room_objects))
        var obj = neutral_room_objects[j].instantiate()
        obj.position = Vector2(Util.rand_range_float(-350,350), Util.rand_range_float(-20,280))
        obj.health = min((bm.average_damage / 5.0) * enemy_health_base, enemy_health_base) * 0.5
        new_room.add_child(obj)

    if hive_pity_roll:
        var num_hives := 1
        if Util.rand_range_float(0, 1) < 0.4:
            num_hives = 2
        for i in range(num_hives):
            var obj = neutral_room_objects[0].instantiate()
            obj.position = Vector2(Util.rand_range_float(-150,150), Util.rand_range_float(-20,180))
            obj.health = min((bm.average_damage / 5.0) * enemy_health_base, enemy_health_base) * 0.5
            new_room.add_child(obj)

    if hive_pity_roll:
        new_room.get_node("DOOR").should_auto_open = true
        new_room.get_node("DOOR/Keyhole").visible = false
    else:
        var room_hardness := (rooms_reached+1)*hardness_per_room
        var hardness: int = 0
        var enemy_health: float = min((bm.average_damage / 5.0) * enemy_health_base, enemy_health_base)
        enemy_health *= min((bm._attack_cooldown_base / bm.attack_cooldown), 1.0)

        if Util.rand_range_float(0, 1) < all_one_enemy_room_chance:
            var i = Util.weighted_random_choice(enemy_object_weights,enemy_object_total_weight)
            var to_spawn: int = max(float(room_hardness) / enemy_object_hardnesses[i], 2)
            if to_spawn > max_enemies_per_room:
                enemy_health *= float(to_spawn) / max_enemies_per_room
                to_spawn = max_enemies_per_room
            for j in range(int(to_spawn)):
                var obj = enemy_objects[i].instantiate()
                obj.health = int(enemy_health * Util.rand_range_float(0.8, 1.2))
                obj.position = Vector2(Util.rand_range_float(-350,350), Util.rand_range_float(-20,280))
                new_room.add_child(obj)
        else:
            var enemy_count = 0
            while hardness < room_hardness:
                var i = Util.weighted_random_choice(enemy_object_weights,enemy_object_total_weight)
                var obj_hardness = enemy_object_hardnesses[i]
                if hardness + obj_hardness > room_hardness:
                    continue
                hardness += obj_hardness
                if enemy_count <= max_enemies_per_room:
                    var obj = enemy_objects[i].instantiate()
                    obj.health = int(enemy_health * Util.rand_range_float(0.8, 1.2))
                    obj.position = Vector2(Util.rand_range_float(-350,350), Util.rand_range_float(-20,280))
                    new_room.add_child(obj)
                    enemy_count += 1
                else:
                    for node in new_room.get_children():
                        if node.is_in_group("enemy"):
                            node.health += int(enemy_health * Util.rand_range_float(1.1, 1.3))

    # Choose a random screen colour
    next_color = Color.from_hsv(randf(),randf()*0.1+0.05,1)


var room_transitioning:=false
var room_transition_t:float=0

func start_transition_to_next_room():
    room_transitioning=true
    room_transition_t=0
    bm.visible=false
    if rooms_reached<len(roman_numerals):
        room_num_label.text = roman_numerals[rooms_reached-1]
    else:
        room_num_label.text = str(rooms_reached)
    if len(room_num_label.text)>4:
        room_num_label.add_theme_font_size_override("font", 400)
    room_num_label.visible=true
    room_swoosh_sfx.play()
    mm.enable_next_layer()
    text_t =0.0
    for particles in get_tree().get_nodes_in_group("acid_trail"):
        particles.emitting=false

func finish_transition_to_next_room():
    room_transitioning=false
    room_transition_t=0
    next_room.position = Vector2(0,0)
    if current_room:
        current_room.queue_free()
    current_room=next_room
    current_color = next_color
    next_room=null
    for b in get_tree().get_nodes_in_group("bees"):
        b.position = Vector2(0,SCREEN_HEIGHT/2-16)
    bm.visible=true
    bm._iframes = bm.iframes
    for particles in get_tree().get_nodes_in_group("acid_trail"):
        particles.emitting=true


var text_t := 1.0;
func finish_label():
    room_num_label.visible=false


func _process(delta):
    text_t+=delta/TEXT_STAY_ON_TIME
    if text_t>=1:
        finish_label()

    if room_transitioning:
        room_transition_t+=delta/ROOM_TRANSITION_TIME_SECS
        # apply room movement
        var t := Util.cubic_ease_out(room_transition_t)
        if current_room!=null:
            current_room.position = Vector2(0,SCREEN_HEIGHT*t)
        next_room.position = Vector2(0,SCREEN_HEIGHT*(t-1))
        cm.color = lerp(current_color,next_color,t)
        AudioServer.set_bus_volume_db(1, lerp(-3.0,0.0,room_transition_t)) #linear
        # music_lowpass.cutoff_hz = lerp(2000,20000,room_transition_t) #linear
        if room_transition_t>=1:
            finish_transition_to_next_room()

func make_and_transition_to_room():
    load_next_room()
    start_transition_to_next_room()


var music_lowpass:AudioEffectLowPassFilter=null

func _ready():
    music_lowpass=AudioServer.get_bus_effect(1,0)
    cm = get_tree().get_first_node_in_group("CanvasModulate")
    load_next_room()
    finish_transition_to_next_room() # skip transition

    for w in enemy_object_weights:
        enemy_object_total_weight+=w
