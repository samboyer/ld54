class_name AcidBeeSwarmCentre
extends Targetable

func damage(amount: int, source: Bee):
    get_parent().damage(amount)
    super(amount, source)

func on_death():
    get_parent().on_death()
