class_name Stagger
extends Node

signal staggered
signal stagger_decreased (diff: int)
signal max_stagger_changed (diff: int)

@export var max_stagger: int = 3 : set = set_max_stagger, get = get_max_stagger
@export var stagger_immortality : bool = false

var immortality_timer: Timer = null

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
	if (value < stagger and stagger_immortality) or (stagger==0 and value!=max_stagger):
		return
		
	var clamped_value = clampi(value, 0, max_stagger)
	
	if clamped_value != stagger:
		var difference = clamped_value - stagger
		stagger = value
		stagger_decreased.emit(difference)
		
		if stagger <= 0:
			staggered.emit()
			Events.camera_shake.emit(2,20)
	else:
		print_debug("sum ting wong")
		
func get_stagger() -> int:
	return stagger

func stagger_recover() -> void:
	stagger=max_stagger

func set_immortality(value: bool):
	stagger_immortality = value

func get_immortality() -> bool:
	return stagger_immortality

func set_temporary_immortality(time: float):
	if immortality_timer == null:
		immortality_timer = Timer.new()
		immortality_timer.one_shot = true
		add_child(immortality_timer)
	
	if immortality_timer.timeout.is_connected(set_immortality):
		immortality_timer.timeout.disconnect(set_immortality)
	
	immortality_timer.set_wait_time(time)
	immortality_timer.timeout.connect(set_immortality.bind(false))
	stagger_immortality = true
	immortality_timer.start()
