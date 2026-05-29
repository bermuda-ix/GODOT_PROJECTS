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

func phase_change(health : int):
	if phases.size()<=0:
		return
	elif health<=phases.get(cur_phase-1):
		#actor.stagger_recover()
		#phases.pop_front()
		health=phases.get(cur_phase-1)
		cur_phase+=1
		next_phase.emit()
		
func reset_phases() -> void:
	phases=default_phases

func is_final_phase() -> bool:
	if cur_phase==phases[phases.size()-1]:
		return true
	else:
		return false
