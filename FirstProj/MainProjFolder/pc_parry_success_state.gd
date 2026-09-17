extends LimboHSM

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity
@export var hit_stop : HitStop
@onready var dur : Timer = Timer.new()
@onready var success : bool = false
@onready var enemy_success := false

@export var state_machine : LimboHSM

@onready var starting : float
@onready var dash_distance := 500.0
@onready var ranged_counter := false
@export var attack_dash_active := false
@export var clash_animation := "clashed"
@export var attack_1 : LimboState

signal dur_timeout


func _ready() -> void:
	Events.parry_success.connect(enemy_counter)
	add_child(dur)
	dur.autostart=false
	dur.one_shot=true
	dur.ignore_time_scale=true
	dur.timeout.connect(do_nothing)

func _enter() -> void:
	print_debug("successful parry")
	pc.attack_timer.stop()
	var _attack_anim=attack_1.attack
	var _marker_time=anim_player.get_animation(_attack_anim).get_marker_time("Attack_connect")
	anim_player.seek(_marker_time, true)
	#assert(anim_player.current_animation_position==_marker_time)
	anim_player.pause()
	hit_stop.hit_stop(0.1, 5)
	pc.knockback=Vector2.ZERO
	pc.velocity.x=0
	dur.start(10)
	success=false
	enemy_success=false

func _update(delta: float) -> void:
	if get_active_state()==pc.await_input:
		pc.velocity.x=0+pc.knockback.x
	attack_dash(delta)
	#if pc.velocity.x!=0:
		#print_debug(pc.velocity.x)
	if enemy_success:
		return
	if Input.is_action_just_pressed("attack"):
		dur.stop()
		pc.velocity.x=0
		success=true
		pc.parry_stance=false
		pc.light_attack_index=wrapi(pc.light_attack_index+1, 0, 3)
		attack_1.attack=pc.light_attacks[pc.light_attack_index]
		hit_stop.end_hit_stop()
		Events.parry_success.emit("riposte")
		#pc.parry_success("riposte")
		#pc.state_machine.dispatch(&"start_attack")
		#pc.attack_state.dispatch(&"next_attack")
		
	elif Input.is_action_just_pressed("Dodge"):
		dur.stop()
		success=true
		pc.parry_stance=false
		Events.parry_success.emit("dodge")
		state_machine.dispatch(&"start_dodge")
		hit_stop.end_hit_stop()
		dur.stop()
	elif Input.is_action_just_pressed("special_attack"):
		dur.stop()
		success=true
		pc.parry_stance=false
		if ranged_counter:
			Events.parry_success.emit("heavy_riposte_ranged")
		else:
			Events.parry_success.emit("heavy_riposte")
		dispatch(&"heavy_riposte")
		hit_stop.end_hit_stop()
		dur.stop()
	else:
		pass
	
func _exit() -> void:
	pc.attack_timer.paused=false
	pc.attack_timer.stop()
	success=false
	pc.attacking=false
	#pc.hurt_box_detect.disabled=false

func do_nothing() -> void:
	Events.parry_success.emit("nothing")
	state_machine.dispatch(&"no_nothing")
	
	hit_stop.end_hit_stop()
	pc.clash_timer.start()
	
func enemy_counter(_value : String = "") -> void:
	if _value=="enemy_light_counter":
		pc.start_attack_timer(0.2)
		success=true
		enemy_success=true
		pc.attacking=false
		
func attack_dash(_delta) -> void:
	if not attack_dash_active:
		pc.velocity.x=lerpf(pc.velocity.x, 0, 0.75)
		return
	else:
		pc.move_and_slide()
		print_debug(pc.velocity.x)
		pc.velocity.x=lerpf(pc.velocity.x, 0, 0.2*_delta)

func attack_dash_setup(_lunge_distance := 50.0) -> void:
	pc.velocity.x=_lunge_distance*-pc.face_dir
	starting = pc.global_position.x
	
