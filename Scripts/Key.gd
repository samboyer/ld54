class_name Key
extends Area2D

@export
var tex_normal: Texture2D = null
@export
var tex_hover: Texture2D = null

@export
var bm: BeesManager = null

var key_picked_up := false

# Called when the node enters the scene tree for the first time.
func _ready():
    bm = get_tree().get_first_node_in_group("BeesManager")

var key_bee_threshold = 100;

func _input(event):
    if (event is InputEventMouseButton
            and event.pressed and mouse_in):
        if (bm.centre_of_mass - self.position).length() < key_bee_threshold:
            print('BEE in RANGE')
            var b = get_tree().get_first_node_in_group("bees")
            get_parent().remove_child(self)
            b.add_child(self)
            position = Vector2(0,0)
            get_child(0).set_texture(tex_normal)
            key_picked_up = true

        else:
            print('BEE NOT in RANGE')

var mouse_in = false

func _on_mouse_entered():
    if not key_picked_up:
        mouse_in = true
        get_child(0).set_texture(tex_hover)

func _on_mouse_exited():
    if not key_picked_up:
        mouse_in = false
        get_child(0).set_texture(tex_normal)
