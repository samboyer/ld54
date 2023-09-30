class_name Targetable
extends Node2D

@export var targetable: bool = true
@export var health: int = 100

func _ready():
    self.add_to_group("targetable")

func damage(amount):
    health -= amount
    if health <= 0:
        print("Mamma mia! I'm a dead-a!")