class_name Falling extends LimboState

@export var actor : Node2D
@export var state_machine : LimboHSM

func _update(delta: float) -> void:
	actor.velocity.y += actor.gravity * delta
	actor.move_and_slide()
	if actor.is_on_floor():
		state_machine.dispatch(&"landed")
