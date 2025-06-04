extends LimboHSM

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity
@export var hit_stop : HitStop
@onready var dur : Timer = Timer.new()

signal dur_timeout

func _ready() -> void:
	add_child(dur)
	dur.autostart=false
	dur.one_shot=true
	dur.ignore_time_scale=true
	

func _enter() -> void:
	print("successful parry")
	hit_stop.hit_stop(0.1, 1)
	dur.start(3)

func _update(delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		pc.state_machine.dispatch(&"riposte")
		hit_stop.end_hit_stop()
	elif Input.is_action_just_pressed("Dodge"):
		pc.state_machine.dispatch(&"dodge_back")
		hit_stop.end_hit_stop()
	elif Input.is_action_just_pressed("special_attack"):
		pc.state_machine.dispatch(&"heavy_riposte")
		hit_stop.end_hit_stop()
		
	


func _on_dur_timeout() -> void:
	pc.state_machine.dispatch(&"no_nothing")
	hit_stop.end_hit_stop()
