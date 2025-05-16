class_name HitStop

extends Node
@onready var dur : Timer = Timer.new()
@onready var time_left : float

signal hit_stop_finished

func _ready() -> void:
	add_child(dur)
	dur.autostart=false
	dur.one_shot=true
	dur.ignore_time_scale=true

func hit_stop(time_scale : float, duration : float):
	Engine.time_scale = time_scale
	dur.start(duration)
	await(dur.timeout)
	Engine.time_scale = 1.0
	hit_stop_finished.emit()

func get_time_left()->float:
	return dur.time_left
	
func end_hit_stop():
	Engine.time_scale = 1.0
