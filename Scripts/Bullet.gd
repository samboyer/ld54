class_name Bullet
extends Area2D

var direction: Vector2 = Vector2(0, 0):
    get:
        return direction
    set(value):
        direction = value.normalized()
var speed: float = 100
var lifetime: float = 5.0
var penetration: int = 3

var death_cooldown: float = 1.0
var dead: bool = false

var _kills: int = 0

var bm: BeesManager

func _ready():
    bm = get_tree().get_first_node_in_group('BeesManager')

func _process(delta):
    if not dead:
        position += direction * delta * speed
        lifetime -= delta
    if lifetime < 0:
        destroy()
    if dead:
        death_cooldown -= delta
        if death_cooldown < 0:
            queue_free()

func destroy():
    dead = true
    $Sprite2D.visible = false
    $Particles.emitting = true
    $CollisionShape2D.disabled = true

func _on_body_entered(body:Node2D):
    if not dead:
        if body is Bee:
            if not bm.invulnerable:
                body.kill()
                bm.damage()
                _kills += 1
                if _kills >= penetration:
                    destroy()
        elif body is Enemy:
            pass
        else:
            destroy()
