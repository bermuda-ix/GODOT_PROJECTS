extends LimboState

@export var actor : Node2D
@export var state_machine : LimboHSM
@export var jump_handler : JumpHandler

func _enter() -> void:
	actor.prev_speed=actor.current_speed
	#print("jumping")
	jump_handler.handle_jump(0.5)
	actor.state="JUMP"
	if actor.current_speed < 0:
		actor.current_speed = -actor.jump_speed
	else:
		actor.current_speed = actor.jump_speed

func _update(delta: float) -> void:
	if actor.is_on_floor():
		state_machine.dispatch(&"land")
