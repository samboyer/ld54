class_name AcidBee
extends CharacterBody2D

var maxspeed := 1000
var accel := 8000
var jitter: int = 50

var target: Node2D
var bm: BeesManager

@onready var beeGhostObj = preload("res://Objects/BeeGhost.tscn")

func _ready():
    bm = get_tree().get_first_node_in_group('BeesManager')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
    if target != null:
        var jitter_vector := Vector2(Util.rand_range(-jitter, jitter), Util.rand_range(-jitter, jitter))
        var dir := (target.position - self.position + jitter_vector).normalized() * accel
        velocity += dir * delta
        var damping := velocity * -3
        velocity += damping * delta
        velocity = velocity.limit_length(maxspeed)
        move_and_slide()
        $Sprite2d.flip_h = velocity.x < 0


func kill():
    var beeGhost = beeGhostObj.instantiate()
    beeGhost.initial_position = position
    get_parent().add_child(beeGhost)
    queue_free()

func _on_area_2d_body_entered(body:Node2D):
    if body is Bee and not bm.invulnerable:
        body.kill()
        bm.damage()
