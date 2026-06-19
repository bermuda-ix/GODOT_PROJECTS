class_name PhasesHandler extends Node

@export var health : Health
@export var actor : Node2D
@export var sm :LimboHSM

@export var phase_active : bool
@export var phases : Array[int]
var default_phases : Array[int]
@export var cur_phase : int = 1

signal next_phase

func _ready() -> void:
	default_phases = phases.duplicate()

func phase_change(_health : int):
	print_debug(_health," ,",phases.get(cur_phase-1))
	if phases.size()<=0:
		return
	elif _health<=phases.get(cur_phase-1):
		#actor.stagger_recover()
		#phases.pop_front()
		_health=phases.get(cur_phase-1)
		cur_phase+=1
		next_phase.emit()
		
func reset_phases() -> void:
	phases=default_phases

func is_final_phase() -> bool:
	print_debug(phases.size())
	if cur_phase==phases.size()+1:
		return true
	else:
		return false
