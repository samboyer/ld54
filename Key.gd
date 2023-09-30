extends RigidBody2D

@export
var tex_normal:Texture2D = null
@export
var tex_hover:Texture2D = null

@export
var bm:BeesManager = null

# Called when the node enters the scene tree for the first time.
# func _ready():

var key_bee_threshold = 100;

func _input(event):
	if event is InputEventMouseButton:
		if (event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
			and (bm.center_of_mass - self.position).length() < key_bee_threshold):
			if mouse_in:
				bm.spawn_bee()

var mouse_in = false

func _on_mouse_entered():
	mouse_in = true
	print("AAAAA")
	get_child(0).set_texture(tex_hover)

func _on_mouse_exited():
	mouse_in = false
	print("BBBB")
	get_child(0).set_texture(tex_normal)
