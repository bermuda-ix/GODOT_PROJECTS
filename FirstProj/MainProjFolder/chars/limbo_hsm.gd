extends LimboHSM


@export var actor : Node2D

func _ready() -> void:
	initialize(actor)
	set_active(true)
	initial_state=actor.idle
	add_transition(actor.idle, actor.attack, &"attack_mode")
	
