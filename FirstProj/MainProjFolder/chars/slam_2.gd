extends LimboState

@export var actor : Node2D

func _enter() -> void:
	print_debug("begining slam")

func _update(delta: float) -> void:
	print_debug("hanging")

func _exit() -> void:
	if actor.is_on_floor():
		print_debug("landed correctly")
	else:
		print_debug("exiting too soon")
