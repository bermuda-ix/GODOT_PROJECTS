extends LimboState

@export var actor : Node2D

func _enter() -> void:
	print("begining slam")

func _update(delta: float) -> void:
	print("hanging")

func _exit() -> void:
	if actor.is_on_floor():
		print("landed correctly")
	else:
		print("exiting too soon")
