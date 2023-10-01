class_name BeesManager
extends Node2D

@onready
var beeObj = preload("res://Objects/bee2.tscn")

@export
var STARTING_NUM_BEES: int = 100
var num_bees: int = 0


var label_hp: Label = null
var label_dmg: Label = null
var label_cooldown: Label = null
var powerup_bar: Node = null

var SHOOT_PULL_INWARD: float = 0.5

@export var attack_cooldown: float = 0.5
@export var attack_bees: int = 1
@export var attack_jitter: float = 100.0
@export var iframes: float = 0.05
@export var attack_range: float = 250
@export var powerup_duration: float = 5.0
var invulnerable: bool = false
var _iframes: float = 0.0
var _attacking: bool = false
var _attack_cooldown_counter: float = 0.0
var _attack_cooldown_base: float

var _powerup_auto: float = 0.0
var _powerup_invuln: float = 0.0
var _powerup_icon: float = 0.0

@export var camera: Camera2D
@export var com_object: Area2D
@export var bee_fire_sfx: AudioStreamPlayer
@export var bee_die_sfx: AudioStreamPlayer
@export var game_over_sfx: AudioStreamPlayer
@export var game_over_panel: Node2D
@export var mm:MusicManager
@export var rm:RoomManager
@export var label_gameover_rooms:Label
@export var label_gameover_num_killed:Label

var reticule: Node2D
var centre_of_mass:Vector2 = Vector2.ZERO

var average_damage: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
    label_hp = get_tree().get_first_node_in_group('hp_number')
    label_dmg = get_tree().get_first_node_in_group('dmg_number')
    label_cooldown = get_tree().get_first_node_in_group('cooldown_number')
    powerup_bar = get_tree().get_first_node_in_group('powerup_bar')

    _attack_cooldown_base = attack_cooldown

    add_bees(STARTING_NUM_BEES, Vector2.ZERO)

    reticule = find_child("Reticule")
    Util.num_enemies_killed = 0

func add_bees(num_to_spawn, spawn_pos:Vector2, freeze_time:float=0.0):
    for i in range(num_to_spawn):
        var x:Bee = beeObj.instantiate()
        x.velocity = Vector2(Util.rand_range_float(-100,100), Util.rand_range_float(-100,100))
        x.freeze_time=freeze_time
        x.z_index = 1
        add_child(x)
        x.position = spawn_pos#+Vector2(randi() % 500 - 250, randi() % 500 - 250)
    num_bees += num_to_spawn


func _input(event):
    if event.is_action_pressed("attack"):
        _attacking = true
    elif event.is_action_released("attack"):
        _attacking = false

func find_target() -> Targetable:
    var target: Targetable = null
    var target_distance: float = 10000
    var mouse_position: Vector2 = get_global_mouse_position()
    for node in get_tree().get_nodes_in_group("targetable"):
        var dist = node.global_position.distance_to(mouse_position)
        if node.targetable and dist < attack_range and dist < target_distance:
            target = node
            target_distance = dist
    return target

func find_free_bee() -> Bee:
    for b in get_tree().get_nodes_in_group("bees"):
        if not b.attacking:
            return b
    return null

func fire_a_bee():
    var fired_bee: Bee = find_free_bee()
    if fired_bee != null:
        var crit = fired_bee.attack(reticule.target)
        camera.jitter(attack_jitter)
        if crit:
            camera.jitter(attack_jitter)
        _attack_cooldown_counter = attack_cooldown
        for b in get_tree().get_nodes_in_group("bees"):
            if b != fired_bee:
                b.position = lerp(b.position, centre_of_mass, SHOOT_PULL_INWARD)
                # b.velocity = (centre_of_mass - b.position).normalized() * 100.0
    bee_fire_sfx.pitch_scale = Util.rand_range_float(1.0, 1.3)
    bee_fire_sfx.play()

func gameover():
    game_over_panel.visible = true
    game_over_sfx.play()
    mm.stop_all()
    label_gameover_rooms.text = str(rm.rooms_reached) + " ROOMS CLEARED"
    label_gameover_num_killed.text = str(Util.num_enemies_killed) + " ACIDS DEFEATED"

# called when a bee dies
func damage():
    if rm.room_transitioning:
        return
    invulnerable = true
    _iframes = iframes
    if num_bees==0:
        gameover()
    bee_die_sfx.play()


func powerup(powerup_type: Powerup.PowerupType):
    match powerup_type:
        Powerup.PowerupType.Speed:
            attack_cooldown = ((attack_cooldown - (_attack_cooldown_base / 4)) * 0.9) + (_attack_cooldown_base / 4)
            $PowerupIcon.texture = load("res://Textures/powerup-0.png")
        Powerup.PowerupType.Power:
            for b in get_tree().get_nodes_in_group("bees"):
                b.damage *= 1.2
            $PowerupIcon.texture = load("res://Textures/powerup-1.png")
        Powerup.PowerupType.Auto:
            _powerup_auto = powerup_duration
            $PowerupIcon.texture = load("res://Textures/powerup-2.png")
        Powerup.PowerupType.Invuln:
            _powerup_invuln = powerup_duration
            $PowerupIcon.texture = load("res://Textures/powerup-3.png")
    $PowerupIcon.visible = true
    _powerup_icon = 1.0
    print("a")

# # Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    reticule.target = find_target()

    _powerup_auto = max(_powerup_auto - delta, 0.0)
    _powerup_invuln = max(_powerup_invuln - delta, 0.0)

    if _powerup_auto > 0.0 or _powerup_invuln > 0.0:
        powerup_bar.visible = true
        if _powerup_invuln > _powerup_auto:
            powerup_bar.get_node("Bar").color = Color(1., .38, .26)
        else:
            powerup_bar.get_node("Bar").color = Color(1., .8, 0)
        powerup_bar.get_node("Bar").scale.x = max(_powerup_auto, _powerup_invuln) / powerup_duration
    else:
        powerup_bar.visible = false

    _powerup_icon = max(_powerup_icon - delta, 0.0)
    $PowerupIcon.position = centre_of_mass + Vector2(0, -50 * (2 - _powerup_icon))
    $PowerupIcon.modulate.a = _powerup_icon
    $PowerupIcon.visible = _powerup_icon > 0.0

    _iframes = max(_iframes - delta, 0.0)
    invulnerable = _iframes > 0.0

    if _powerup_invuln > 0.0:
        invulnerable = true
        var i: int = 0
        for b in get_tree().get_nodes_in_group("bees"):
            # Shift hue
            b.modulate = Color.from_hsv((_powerup_invuln * 3) + (i / 1.618), 1, 1)
            i += 1
    else:
        for b in get_tree().get_nodes_in_group("bees"):
            b.modulate = Color(1, 1, 1)

    _attack_cooldown_counter = max(_attack_cooldown_counter - delta, 0.0)
    if _powerup_auto > 0.0:
        _attack_cooldown_counter = max(_attack_cooldown_counter - 2 * delta, 0.0)
    reticule.active = _attack_cooldown_counter <= 0.0
    if _attacking and _attack_cooldown_counter <= 0 and not rm.room_transitioning:
        for _i in range(attack_bees):
            fire_a_bee()

    centre_of_mass = Vector2.ZERO
    average_damage = 0.0
    for b in get_tree().get_nodes_in_group("bees"):
        centre_of_mass += b.position
        average_damage += b.damage
    if num_bees > 0:
        average_damage /= num_bees
    centre_of_mass /= num_bees
    com_object.position = centre_of_mass

    # Update ui
    label_hp.text = str(num_bees)
    label_dmg.text = str(average_damage).pad_decimals(2)
    label_cooldown.text = str(_attack_cooldown_base / attack_cooldown).pad_decimals(2)
