class_name Stagger
extends Node

signal staggered
signal stagger_decreased (diff: int)
signal max_stagger_changed (diff: int)

@export var max_stagger: int = 3 : set = set_max_stagger, get = get_max_stagger

@onready var stagger: int = max_stagger : set = set_stagger, get = get_stagger

func set_max_stagger(value: int):
	var clamped_value = 1 if value <= 0 else value
	
	if not clamped_value == max_stagger:
		var difference = clamped_value - max_stagger
		max_stagger = value
		max_stagger_changed.emit(difference)
		
		if stagger > max_stagger:
			stagger = max_stagger
			
func get_max_stagger() -> int:
	return max_stagger
	
func set_stagger(value: int):
	var clamped_value = clampi(value, 0, max_stagger)
	
	if clamped_value != stagger:
		var difference = clamped_value - stagger
		stagger = value
		stagger_decreased.emit(difference)
		
		if stagger == 0:
			staggered.emit()
	
func get_stagger() -> int:
	return stagger
