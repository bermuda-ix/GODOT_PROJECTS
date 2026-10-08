class_name PhasesHSM extends LimboHSM

@export var phase_1 : LimboState
@export var phase_2 : LimboState

@export var phases : Array[LimboState]

func _init_phase_state_machine():
	initial_state=phase_1
	initialize(self)
	set_active(true)
	
	#add_transition(phase_1, phase_2, &"next_phase")
	
	for i in phases.size():
		if i==phases.size():
			return
		else:
			add_transition(phases[i], phases[i+1], &"next_phase")
