class_name JumpHandler
extends Node

@export var actor : Node2D
@export var state_machine : LimboHSM


func handle_jump(jump_vel : float):
	if actor.jump_timer.is_stopped():
		actor.velocity.y = actor.jump_velocity*jump_vel
		actor.set_state(actor.current_state, actor.States.JUMP)
		if state_machine.get_active_state()==actor.attack:
			state_machine.dispatch(&"jump")
		elif state_machine.get_active_state()==actor.chasing:
			state_machine.dispatch(&"jump")
		actor.jump_timer.start(2)
