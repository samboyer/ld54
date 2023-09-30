class_name Targetable
extends CharacterBody2D

@export var targetable: bool = true
@export var health: int = 50
@export var death_cooldown: float = 1.0
var dead: bool = false

func _ready():
    self.add_to_group("targetable")

func damage(amount):
    health -= amount
    if health <= 0:
        dead = true
        targetable = false
        on_death()

func on_death():
    printerr("on_death() not implemented!")

func _process(delta):
    if dead:
        death_cooldown -= delta
        if death_cooldown <= 0:
            queue_free()