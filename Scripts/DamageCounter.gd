@tool
extends Node2D

# Colour gradient for amount
@export var colour_gradient: Gradient = Gradient.new()
@export var damage_max: int = 100
@export var lifetime: float = 1.0
@export var scale_curve: Curve = Curve.new()
var life: float = 1.0

@export var amount: int = 0:
    get:
        return amount
    set(value):
        amount = value
        $Label.text = str(amount)
        $LabelOutline.text = str(amount)
        var colour: Color = colour_gradient.sample(amount / float(damage_max))
        $Label.modulate = colour

func _ready():
    amount = amount
    life = lifetime
    if is_inside_tree():
        scale *= scale_curve.sample(amount / float(damage_max))

func _process(delta):
    if not is_inside_tree():
        return
    life -= delta
    if life <= 0.0:
        queue_free()
