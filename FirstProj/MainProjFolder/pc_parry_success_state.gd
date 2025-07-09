extends LimboHSM

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity
@export var hit_stop : HitStop
@onready var dur : Timer = Timer.new()
@onready var success : bool = false

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
		success=true
		pc.parry_stance=false
		Events.parry_success.emit("riposte counter")
		pc.state_machine.dispatch(&"riposte")
		hit_stop.end_hit_stop()
		dur.stop()
	elif Input.is_action_just_pressed("Dodge"):
		success=true
		pc.parry_stance=false
		Events.parry_success.emit("dodge counter")
		pc.state_machine.dispatch(&"dodge_back")
		hit_stop.end_hit_stop()
		dur.stop()
	elif Input.is_action_just_pressed("special_attack"):
		success=true
		pc.parry_stance=false
		Events.parry_success.emit("heavy riposte counter")
		pc.state_machine.dispatch(&"heavy_riposte")
		hit_stop.end_hit_stop()
		dur.stop()
		
	
func _exit() -> void:
	pc.attack_timer.paused=false
	pc.attack_timer.stop()
	success=false

func _on_dur_timeout() -> void:
	if success==true:
		return
	Events.parry_failed
	pc.state_machine.dispatch(&"no_nothing")
	hit_stop.end_hit_stop()
	pc.clash_timer.start()
