extends RigidBody2D

@export
var tex_normal: Texture2D = null
@export
var tex_hover: Texture2D = null

@export
var bm: BeesManager = null

# Called when the node enters the scene tree for the first time.
func _ready():
	bm = get_tree().get_first_node_in_group("BeesManager")

var key_bee_threshold = 100;

func _input(event):
	if (event is InputEventMouseButton
			and event.pressed and mouse_in):
		if (bm.centre_of_mass - self.position).length() < key_bee_threshold:
			print('BEE in RANGE')
			get_parent().remove_child(self)
			bm.bees[0].add_child(self)
			position = Vector2(0,0)

		else:
			print('BEE NOT in RANGE')

var mouse_in = false

func _on_mouse_entered():
	mouse_in = true
	print("AAAAA")
	get_child(0).set_texture(tex_hover)

func _on_mouse_exited():
	mouse_in = false
	print("BBBB")
	get_child(0).set_texture(tex_normal)
