extends LimboHSM

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity
@export var hit_stop : HitStop
@onready var dur : Timer = Timer.new()
@onready var success : bool = false

@export var clash_animation := "clashed"
@export var attack_1 : LimboState

signal dur_timeout


func _ready() -> void:
	add_child(dur)
	dur.autostart=false
	dur.one_shot=true
	dur.ignore_time_scale=true
	

func _enter() -> void:
	print_debug("successful parry")
	pc.attack_timer.stop()
	var _attack_anim=attack_1.attack
	var _marker_time=anim_player.get_animation(_attack_anim).get_marker_time("Attack_connect")
	anim_player.seek(_marker_time, true)
	assert(anim_player.current_animation_position==_marker_time)
	anim_player.pause()
	hit_stop.hit_stop(0.1, 1)
	pc.velocity.x=0
	#dur.start(3)

func _update(delta: float) -> void:
	pc.velocity.x=0
	if Input.is_action_just_pressed("attack"):
		pc.velocity.x=0
		success=true
		pc.parry_stance=false
		pc.light_attack_index=wrapi(pc.light_attack_index+1, 0, 3)
		attack_1.attack=pc.light_attacks[pc.light_attack_index]
		hit_stop.end_hit_stop()
		Events.parry_success.emit("riposte")
		pc.parry_success("riposte")
		#pc.state_machine.dispatch(&"start_attack")
		#pc.attack_state.dispatch(&"next_attack")
		
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
	#pc.hurt_box_detect.disabled=false

func _on_dur_timeout() -> void:
	if success==true:
		return
	Events.parry_failed
	pc.state_machine.dispatch(&"no_nothing")
	hit_stop.end_hit_stop()
	pc.clash_timer.start()
