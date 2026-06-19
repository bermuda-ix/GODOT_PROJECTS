class_name ChaseHandler

extends Node

@export var state_machine : StateMachine

func chase():
	#set_state(current_state, States.CHASE)
	state_machine.dispatch(&"start_chase")
