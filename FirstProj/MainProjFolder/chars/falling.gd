class_name Falling extends LimboState

@export var actor : Node2D
@export var state_machine : LimboHSM

func _enter() -> void:
	actor.hb_collision.set_deferred("disabled", false)

func _update(delta: float) -> void:
	actor.velocity.y += actor.gravity * delta
	actor.velocity.x=lerpf(actor.velocity.x, 0, 0.2)
	actor.move_and_slide()
	if actor.is_on_floor():
		state_machine.dispatch(&"landed")
