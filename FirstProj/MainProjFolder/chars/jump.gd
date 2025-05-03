extends LimboState

@export var actor : Node2D
@export var state_machine : LimboHSM
@export var jump_handler : JumpHandler
@export var jump_vel : float = 0.5

func _enter() -> void:
	actor.prev_speed=actor.current_speed
	#print("jumping")
	jump_handler.handle_jump(jump_vel)
	actor.state="JUMP"
	if actor.current_speed < 0:
		actor.current_speed = -actor.jump_speed
	else:
		actor.current_speed = actor.jump_speed

func _update(delta: float) -> void:
	if actor.is_on_floor() and actor.jump_timer.is_stopped():
		state_machine.dispatch(&"land")

func _exit() -> void:
	print("exiting jump")
