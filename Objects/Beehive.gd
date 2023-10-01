extends Barrel

@export var NUM_EXTRA_BEES = 15

func _ready():
    super()

func on_death():
    var bm:BeesManager = get_tree().get_first_node_in_group("BeesManager")
    bm.add_bees(NUM_EXTRA_BEES,self.position,0.5)
    $Particles.emitting = true
    $BeeParticles.emitting = false
    $BeeParticles2.emitting = false
    $AnimationPlayer.play("beehive_open")