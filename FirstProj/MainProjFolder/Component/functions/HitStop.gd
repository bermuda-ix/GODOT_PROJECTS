class_name HitStop

extends Node
@onready var dur : Timer = Timer.new()
@onready var time_left : float 
@onready var tween: Tween 
@onready var current_time_scale: float = 1.0 : set=set_current_time_scale
@onready var slow_down_ease: bool = false

signal hit_stop_finished

func _ready() -> void:
	add_child(dur)
	dur.autostart=false
	dur.one_shot=true
	dur.ignore_time_scale=true
	dur.timeout.connect(dur_debug)
	
func _process(delta: float) -> void:
	if not dur.is_stopped() and slow_down_ease:
		print_debug(Engine.time_scale)
		
	###If Engine.time_scale doesn't return to 1.0
	#if Input.is_action_just_pressed("DEBUG_KEY"):
		#hit_stop_ease(0.01, 2, 0.9)
	#elif dur.is_stopped():
		#if Engine.time_scale!=1.0:
			#print_debug("ruh roh, ",Engine.time_scale)
			#Engine.time_scale=1.0

func hit_stop(time_scale : float, duration : float):
	Engine.time_scale = time_scale
	dur.start(duration)
	await(dur.timeout)
	Engine.time_scale = 1.0
	hit_stop_finished.emit()

func hit_stop_ease(time_scale_end: float, duration: float, _weight: float):
	tween = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(Engine, "time_scale", time_scale_end, _weight)
	dur.start(duration)
	await(dur.timeout)
	tween.kill()
	Engine.time_scale = 1.0
	hit_stop_finished.emit()

func set_current_time_scale(_value: float):
	current_time_scale=_value
	

func get_time_left()->float:
	return dur.time_left
	
func end_hit_stop():
	if tween != null:
		tween.kill()
	Engine.time_scale = 1.0

func dur_debug():
	print_debug("hit_Stop_ending")
