extends LimboState

@export var pc : PlayerEntity

#func _enter() -> void:
	#pc.state_machine.dispatch(&"return_to_idle")
