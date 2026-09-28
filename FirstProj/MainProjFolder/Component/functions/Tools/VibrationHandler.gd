extends Node

@onready var controller_id = null
@onready var start_weight := 1.0
@onready var end_weight := 0.0
@onready var vibrate_fade_dur : Timer
@onready var vibrate_fade_time : float = 0.0
@onready var vibrate := false
@onready var weight := 0.2

func _ready() -> void:
	vibrate_fade_dur=Timer.new()
	vibrate_fade_dur.autostart=false
	vibrate_fade_dur.one_shot=true
	vibrate_fade_dur.ignore_time_scale=true
	vibrate_fade_dur.timeout.connect(vibrate_end)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		controller_id=event.device
		
func _process(delta: float) -> void:
	pass
	#weight = lerpf(start_weight, end_weight, vibrate_fade_time)
	#if vibrate:
		#print_debug(vibrate_fade_dur.time_left)
		#Input.start_joy_vibration(controller_id, weight, weight, 0)
		#
	#if Input.is_action_just_pressed("DEBUG_KEY"):
		#vibration_fade(1.0, 0.0, 2.0)

#func vibrate() -> void:
	#if Input.has_joy_vibration(controller_id):
		#Input.start_joy_vibration(controller_id, 1.0, 1.0, 0.1)

func vibration_fade(_start_weight := 1.0, _end_weight := 0.0, dur := 1.0) -> void:
	if controller_id==null:
		return
	start_weight=_start_weight
	end_weight=end_weight
	vibrate_fade_dur.start(dur)
	vibrate_fade_time=1/dur
	vibrate=true
	
func vibrate_end() -> void:
	Input.stop_joy_vibration(controller_id)
	vibrate=false
	
	
	
	
