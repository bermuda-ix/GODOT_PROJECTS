extends CharacterBody2D
class_name PlayerEntity

const hit1 = "res://Art_Components/Effects/sound/Socapex - Evol Online SFX - Punches and hits/Socapex - Evol Online SFX - Punches and hits/Socapex - Swordsmall_1.wav"
const hit2 = "res://Art_Components/Effects/sound/Socapex - Evol Online SFX - Punches and hits/Socapex - Evol Online SFX - Punches and hits/Socapex - Swordsmall_2.wav"
const hit3 = "res://Art_Components/Effects/sound/Socapex - Evol Online SFX - Punches and hits/Socapex - Evol Online SFX - Punches and hits/Socapex - Swordsmall_3.wav"

const swing1 = "res://Art_Components/Effects/sound/swishes/swishes/swish-1.wav"
const swing2 = "res://Art_Components/Effects/sound/swishes/swishes/swish-3.wav"
const swing3 = "res://Art_Components/Effects/sound/swishes/swishes/swish-5.wav"
const parry_sfx = "res://Art_Components/Effects/sound/Socapex - Evol Online SFX - Punches and hits/Socapex - Evol Online SFX - Punches and hits/Socapex - big punch.wav"
const shotgun_fire = "res://Art_Components/Effects/sound/mike_koenig-shotgun/mike_koenig-shotgun/10 Guage Shotgun-SoundBible.com-74120584.wav"
const reload = "res://Art_Components/Effects/sound/mike_koenig-shotgun/mike_koenig-shotgun/Chambering A Round-SoundBible.com-854171848.wav"


const CLOCKWISE=PI/2
const COUNTER_CLOCKWISE=-PI/2
#signals
signal flip
signal jump_out_signal

#Player Stats
@export var movement_data : PlayerMovementData
@export var health: Health
@export var hitbox: HitBox
@export var ammo : int = 0
@export var TARGET_LOCK = preload("res://Component/effects/target_lock.tscn")
@onready var clash_power: ClashPower = $ClashPower
@onready var clash_timer: Timer = $ClashPower/ClashTimer
@onready var stairs_detected : bool = false
@onready var stairs_release : bool = true


#Base FSM
enum States {IDLE, WALKING, JUMP, ATTACK, SPECIAL_ATTACK, WALL_STICK, PARRY, DODGE, SPRINTING,
FLIP,THRUST, HIT, STAGGERED}
@onready var state_machine: LimboHSM = $StateMachine
@onready var idle: LimboState = $StateMachine/Idle
@onready var walking: LimboState = $StateMachine/Walking
@onready var sprint: LimboState = $StateMachine/Sprint
@onready var jump_state: LimboState = $StateMachine/JumpState
@onready var falling_state: LimboState = $StateMachine/FallingState
@onready var landed: LimboState = $StateMachine/Landed
@onready var wall_stick: LimboState = $StateMachine/WallStick
@onready var special_attack: LimboState = $StateMachine/SpecialAttack
@onready var parry_state: LimboState = $StateMachine/ParryState
@onready var dodge_state: LimboState = $StateMachine/DodgeState
@onready var flip_state: LimboState = $StateMachine/FlipState
@onready var staggered: LimboState = $StateMachine/Staggered
@onready var hit: LimboState = $StateMachine/Hit
@onready var recovery: LimboState = $StateMachine/Recovery

#Parry Success State
@onready var parry_success_state: LimboHSM = $StateMachine/ParrySuccessState
@onready var riposte: LimboState = $StateMachine/ParrySuccessState/Riposte
@onready var heavy_riposte: LimboState = $StateMachine/ParrySuccessState/HeavyRiposte
@onready var dodge_back: LimboState = $StateMachine/ParrySuccessState/DodgeBack
@onready var nothing: LimboState = $StateMachine/ParrySuccessState/Nothing
@onready var await_input: LimboState = $StateMachine/ParrySuccessState/AwaitInput

#Attack Combos
@onready var attack_state: LimboHSM = $StateMachine/AttackState
@onready var attack_1: LimboState = $StateMachine/AttackState/Attack1
@onready var attack_2: LimboState = $StateMachine/AttackState/Attack2
@onready var attack_3: LimboState = $StateMachine/AttackState/Attack3
@onready var special_combo: LimboState = $StateMachine/AttackState/SpecialCombo
@onready var special_combo_2: LimboState = $StateMachine/AttackState/SpecialCombo2
@onready var dash_attack: LimboState = $StateMachine/AttackState/DashAttack


@onready var atk_1_resume : bool = false
@onready var atk_2_resume : bool = false

@onready var cur_combo : LimboState = attack_1

#FSM for lock on
enum CombatStates {LOCKED, UNLOCKED}
@onready var combat_states: LimboHSM = $CombatStates
@onready var locked: LimboState = $CombatStates/Locked
@onready var unlocked: LimboState = $CombatStates/Unlocked

#FSM for combo attacks:
enum ComboStates {ATK_1,ATK_2,ATK_3,SPC_ATK,SPC_ATK_STRONG,SPC_ATK_BACK,THRUST}

var state: States = States.IDLE
var prev_state: States = States.IDLE

var combat_state: CombatStates = CombatStates.UNLOCKED
var combo_state: ComboStates = ComboStates.ATK_1

var double_jump_flag = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#wall jump state
var just_wall_jump = false
#parry state
var parry_stance=false
#attack combo up to 3
var atk_chain = 0
var sp_atk_chn = 0
#true = facing right fals= facing left
var face_right = true
var face_dir = clampi(1, -1, 1)
var input_dir=Input.get_axis("walk_left","walk_right")
#dodge dir
#var dodge_state = false

var dodge_dist = 0.0
var dodge_succ = false
var dodge_v = 0.0
var falling : bool = false
var jumping : bool = false

var cur_state = "IDLE"
var previous = "IDLE"
var atk_state="ATK_1"

#Animation var
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var clash_visual: GPUParticles2D = $AnimatedSprite2D/GPUParticles2D


@onready var speech: Label = $Speech
#Cutscenes
@onready var anim_count : int = 0
@onready var cutscene_handler: CutsceneHandler = $CutsceneHandler




@onready var path_speed : int = 0 : set=set_path_speed
@onready var path_start : bool = false : set=set_path_start
@export var camera_pos : camera_position
#@onready var camera_2d: Camera2D = $Camera2D
var input_axis

#Quick-Time Events
@onready var qte_handler: QTEHandler = $QTEHandler
signal attack_qte
signal dodge_qte
signal block_qte
signal special_atk_qte
signal no_input_qte

@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var attack_timer = $AttackTimer
@onready var hit_timer = $HitTimer
@onready var parry_timer = $ParryTimer
@onready var dodge_timer = $DodgeTimer
@onready var starting_position : set = set_start_pos, get = get_start_pos
@onready var label = $STATE

@onready var hit_box: HitBox = $AnimatedSprite2D/HitBox
@onready var hb_collision: CollisionShape2D = $AnimatedSprite2D/HitBox/HBCollision
@onready var pb_rot: CollisionShape2D = $AnimatedSprite2D/ParryBox/PBRot
@onready var parry_box: ParryBox = $AnimatedSprite2D/ParryBox
@onready var counter_box_collision = $CounterBox/CounterBoxCollision
@onready var stagger: Stagger = $Stagger


@onready var sprite_fx: AnimatedSprite2D = $AnimatedSprite2D/sprite_fx
@onready var hurt_box_detect = $HurtBox/CollisionShape2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var hurt_box = $HurtBox
@onready var shotty = $AnimatedSprite2D/Shotty
@onready var sp_atk_hit_box = $AnimatedSprite2D/Shotty/SpAtkHitBox
@onready var sp_atk_cone = $AnimatedSprite2D/Shotty/SpAtkHitBox/SpAtkCone
@onready var cpu_particles_2d = $AnimatedSprite2D/Shotty/CPUParticles2D
@onready var audio_stream_player_2d = $AudioStreamPlayer2D
@onready var hit_sound = hit1
@onready var player_hit: GPUParticles2D = $AnimatedSprite2D/PlayerHit
@onready var hit_stop: HitStop = $HitStop

#Moving rooms
@onready var next_room : int = 0
@onready var cur_room : int = 0
@onready var prev_room : int = 0
@onready var entry_pos : int = 0
@onready var prev_starting_pos : int = 0
@onready var in_door_way : bool = false
@onready var game_controller : GameController

@onready var enemies : Array =[]


var knockback : Vector2
var kb_dir : Vector2 = Vector2.ZERO
var hit_success : bool = false
var forward_thrust : Vector2 = Vector2.ZERO

var hit_box_pos

var walk_anim : String = "walk"
var dodge_anim : String = "dodge"
var dodge_anim_run : String = "dodge"

var attack_combo = "Attack"
var sp_atk_combo = "shotgun_attack"
var air_atk : bool = false
var s_atk : bool = false
var move_axis : int = 1
var sp_atk_type = sp_atk_cone
var sp_atk_dmg :int = 1
var thrust : bool = false

var counter_flag : bool = false
@onready var counter_timer = $CounterTimer

var target
var target_string_test : String = "NONE"
var target_direction
var movement
var flip_speed
var target_right : bool = false
var vector_away : Vector2 = Vector2.ZERO
var target_below : bool = false
var vel_y : float = 0.0
var hitstop_time_left : float
var high_target : bool = false

#locked on target info
@onready var target_testing = $TargetLocking/TargetTesting
@onready var target_locking = $TargetLocking
@onready var target_size_x=0
@onready var target_size_y=0
@onready var target_pos_y=0
@onready var target_pos_x=0
@onready var target_top=0
@onready var target_left_edge=0
@onready var target_right_edge=0
@onready var vel_x=0
#flipping
var high_target_jump_height
@onready var jump_out_timer = $JumpOutTimer
var flipped_over : bool = false

#DEBUG FLAGS TBR
var stuck : bool = false

func _ready():
	hit_box_pos=hit_box.position
	hb_collision.disabled=true

	pb_rot.disabled=true
	set_start_pos(global_position)
	sp_atk_type = sp_atk_cone
	load_player_data()
	Events.set_player_data.connect(save_player_data)
	Events.parried.connect(parry_success)
	flip.connect(flip_over)
	jump_out_signal.connect(jump_out)
	_init_state_machine()
	_init_combat_state_machine()
	_init_parry_success_state_machine()
	_init_attack_states()

func _init_state_machine():
	state_machine.initial_state=idle
	state_machine.initialize(self)
	state_machine.set_active(true)
	
	#Return to Idle
	state_machine.add_transition(walking, idle, &"return_to_idle")
	state_machine.add_transition(sprint, idle, &"return_to_idle")
	state_machine.add_transition(attack_state, idle, &"return_to_idle")
	state_machine.add_transition(landed, idle, &"return_to_idle")
	state_machine.add_transition(parry_state, idle, &"return_to_idle")
	state_machine.add_transition(parry_success_state, idle, &"return_from_parry")
	state_machine.add_transition(dodge_state, idle, &"return_to_idle")
	state_machine.add_transition(special_attack, idle, &"return_to_idle")
	state_machine.add_transition(recovery, idle, &"return_to_idle")
	
	#Landing
	state_machine.add_transition(jump_state, landed, &"landing")
	state_machine.add_transition(falling_state, landed, &"landing")
	state_machine.add_transition(dodge_state, landed, &"landing")
	state_machine.add_transition(flip_state, landed, &"landing")
	
	#Recovery
	state_machine.add_transition(hit, recovery, &"recovering")
	state_machine.add_transition(staggered, recovery, &"recovering")
	
	#From Idle
	state_machine.add_transition(idle, walking, &"start_walking")
	state_machine.add_transition(idle, sprint, &"start_sprinting")
	state_machine.add_transition(idle, jump_state, &"start_jumping")
	state_machine.add_transition(idle, attack_state, &"start_attack")
	state_machine.add_transition(idle, dodge_state, &"start_dodge")
	state_machine.add_transition(idle, parry_state, &"start_parry")
	state_machine.add_transition(idle, flip_state, &"start_flip")
	state_machine.add_transition(idle, staggered, &"got_staggered")
	state_machine.add_transition(idle, hit, &"got_hit")
	
	#From Walking
	state_machine.add_transition(walking, sprint, &"start_sprinting")
	state_machine.add_transition(walking, jump_state, &"start_jumping")
	state_machine.add_transition(walking, attack_state, &"start_attack")
	state_machine.add_transition(walking, dodge_state, &"start_dodge")
	state_machine.add_transition(walking, parry_state, &"start_parry")
	state_machine.add_transition(walking, flip_state, &"start_flip")
	state_machine.add_transition(walking, staggered, &"got_staggered")
	state_machine.add_transition(walking, hit, &"got_hit")
	
	#From Sprinting
	state_machine.add_transition(sprint, walking, &"start_walking")
	state_machine.add_transition(sprint, jump_state, &"start_jumping")
	state_machine.add_transition(sprint, attack_state, &"start_attack")
	state_machine.add_transition(sprint, dodge_state, &"start_dodge")
	state_machine.add_transition(sprint, parry_state, &"start_parry")
	state_machine.add_transition(sprint, flip_state, &"start_flip")
	state_machine.add_transition(sprint, staggered, &"got_staggered")
	state_machine.add_transition(sprint, hit, &"got_hit")
	
	#Hit
	state_machine.add_transition(parry_success_state, hit, &"got_hit")
	
	#Attack Combos
	#state_machine.add_transition(attack_state, special_attack, &"attack_to_special")
	#state_machine.add_transition(special_attack, attack_state, &"special_to_attack")
	state_machine.add_transition(jump_state, attack_state, &"jump_attack")
	state_machine.add_transition(jump_state, special_attack, &"jump_spc_attack")
	state_machine.add_transition(dodge_state, attack_state, &"dash_attack")
	state_machine.add_transition(dodge_state, attack_state, &"combo_resume")
	
	state_machine.add_transition(idle, special_attack, &"special_attack")
	state_machine.add_transition(walking, special_attack, &"special_attack")
	state_machine.add_transition(sprint, special_attack, &"special_attack")
	state_machine.add_transition(jump_state, special_attack, &"special_attack")
	state_machine.add_transition(special_attack, jump_state, &"return_from_special")
	#state_machine.add_transition(idle, special_attack, &"special_attack")
	state_machine.add_transition(attack_state, dodge_state, &"start_dodge")
	
	#Flipping State
	state_machine.add_transition(flip_state, jump_state, &"jump_out")
	state_machine.add_transition(flip_state, attack_state, &"flip_attack")
	#state_machine.add_transition(flip_state, jump_state, &"jump_out")
	
	#Counter Success
	state_machine.add_transition(parry_state, parry_success_state, &"parry_successful")
	state_machine.add_transition(dodge_state, parry_success_state, &"dodge_successful")

	#Wall Stick
	state_machine.add_transition(jump_state, wall_stick, &"stick_to_wall")
	state_machine.add_transition(wall_stick, jump_state, &"jump_off_wall")
	state_machine.add_transition(wall_stick, falling_state, &"fall_off_wall")



func _init_combat_state_machine():
	combat_states.initial_state=unlocked
	#label.text=str(unlocked.name)
	combat_states.initialize(self)
	combat_states.set_active(true)
	
	combat_states.add_transition(locked, unlocked, &"unlocking")
	combat_states.add_transition(unlocked, locked, &"locking_on")
	
func _init_parry_success_state_machine():
	parry_success_state.initial_state=await_input
	
	parry_success_state.add_transition(await_input, riposte, &"riposte")
	parry_success_state.add_transition(await_input, heavy_riposte, &"heavy_riposte")
	parry_success_state.add_transition(await_input, dodge_back, &"dodge_back")
	parry_success_state.add_transition(await_input, nothing, &"do_nothing")
	
func _init_attack_states():
	attack_state.initial_state=attack_1

	attack_state.add_transition(attack_1, attack_2, &"next_attack")
	attack_state.add_transition(attack_2, attack_3, &"next_attack")
	attack_state.add_transition(attack_3, attack_1, &"next_attack")
	attack_state.add_transition(attack_1, special_combo, &"special_combo")
	attack_state.add_transition(attack_2, special_combo, &"special_combo")
	attack_state.add_transition(attack_3, special_combo_2, &"special_combo")
	attack_state.add_transition(attack_state.ANYSTATE, dash_attack, &"dash_attack")
	
	#Resume Combos
	attack_state.add_transition(special_combo, attack_2, &"combo_resume")
	attack_state.add_transition(special_combo, attack_3, &"combo_resume_2")
	
	attack_state.add_transition(attack_state.ANYSTATE, attack_1, &"reset_combo")

func _process(_delta):
	#if anim_player.is_playing():
		#print("animation playing")
	#else:
		#print("no play")
	if clash_power.clash_power>0:
		clash_visual.self_modulate.a = (1/clash_power.clash_power) +0.1
	else:
		clash_visual.self_modulate.a = 0
	label.text=str(staggered)
	knockback=clamp(knockback, Vector2(-400, -400), Vector2(400, 400) )
	if not cutscene_handler.actor_control_active:
		
		if qte_handler.actor_control_active:
			qte_input()
		return
	#elif state==States.STAGGERED:
		#return
#
	input_axis = Input.get_axis("walk_left", "walk_right")
	vel_x=velocity.x
	#current_state_label()
	get_target_info()
	#previous_state()
	atk_state_debug()
#
	dodge(input_axis)
	#if Input.is_action_just_pressed("walk_right"):
		#face_right = true
		#move_axis = 1
		#parry_box.scale.x=1
	#elif Input.is_action_just_pressed("walk_left"):
		#face_right = false
		#move_axis = -1
		#parry_box.scale.x=-1
	#elif input_axis == 0:
		#move_axis = 0
#
	#
	if(state_machine.get_active_state()!=dodge_state and state_machine.get_active_state()!=special_attack and state_machine.get_active_state()!=flip_state):
		parry()
		attack_animate()
		update_animation(input_axis)
	elif state_machine.get_active_state()==flip_state:
		break_out()
	elif state_machine.get_active_state()==dodge_state:
		if Input.is_action_just_pressed("attack"):
			dash_attack_enter()
	#
	lockon()
	enter_door()
	climb_stairs()

func _physics_process(delta):
	if not cutscene_handler.actor_control_active or not qte_handler.actor_control_active:
		apply_gravity(delta)
		cutscene_acceleration(cutscene_handler.cutscene_dir, delta)
		move_and_slide()

		return
	
	elif state_machine.get_active_state()==flip_state:
		flipping(delta)
		sp_atk()
		move_and_slide()
		
		if is_on_floor():
			if state_machine.get_active_state()==jump_state or (state_machine.get_active_state()==flip_state and flipped_over):
				state_machine.dispatch(&"landing")
				
			
	elif state_machine.get_active_state()==staggered:
		move_and_slide()
		apply_gravity(delta)
		velocity.x=0
	else:
		if combat_states.get_active_state()==locked:
			locked_combat()	
#
		##if dodge_state == true:
			##state = States.DODGE
		
		## Add the gravity.
		if(parry_stance==false):
			apply_gravity(delta) 
		var input_axis = Input.get_axis("walk_left", "walk_right")
		if input_axis<0:
			face_right=true
			face_dir=1
		elif input_axis>0:
			face_right=false
			face_dir=-1
		##Dodge back on success

		

		var wall_hold = false
		if(state_machine.get_active_state()!=dodge_state and parry_stance==false and state_machine.get_active_state()!=flip_state):
			handle_wall_jump(wall_hold, delta)
			jump(input_axis, delta)
			handle_acceleration(input_axis, delta)
			handle_air_acceleration(input_axis, delta)
			apply_friction(input_axis, delta)
			apply_air_resistance(input_axis, delta)
			sp_atk()
		
		
		
		var was_on_floor = is_on_floor()
		velocity=velocity + knockback
		move_and_slide()
		var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
		if just_left_ledge:
			coyote_jump_timer.start()
		just_wall_jump = false
		

		#cur_state)
		#var side
		#if target_right:
			#side = "Right"
		#else:
			#side = "Left"
		
		
		knockback = lerp(knockback, Vector2.ZERO, 0.1)
		forward_thrust = lerp(forward_thrust, Vector2.ZERO, 0.6)
		#wall hold check
		if not is_on_wall() or not Input.is_action_pressed("sprint"):
			wall_hold=false
			gravity = 980
		else:
			state_machine.dispatch(&"stick_to_wall")
			velocity.x =0
			velocity.y = 0
			gravity = 0
	
	#return_to_idle()

# Add the gravity.
func apply_gravity(delta):
	if not is_on_floor():
		if s_atk:
			velocity.y += gravity/3 * movement_data.gravity_scale * delta
		else:
			velocity.y += gravity * movement_data.gravity_scale * delta
	
#condtions to return to idle
func return_to_idle():
	if is_on_floor() and state_machine.get_previous_active_state()==flip_state and flipped_over:
		#"flip end")
		state_machine.dispatch(&"return_to_idle")
		set_collision_mask_value(16384, true)
	
# Handle jump.
func jump(input_axis, delta):

	if is_on_floor(): double_jump_flag = true
	
	if is_on_floor() or coyote_jump_timer.time_left>0.0:
		if Input.is_action_just_pressed("jump"):
			#state = States.JUMP
			state_machine.dispatch(&"start_jumping")
			velocity.y = movement_data.jump_velocity
			
	elif not is_on_floor() and parry_stance==false and state_machine.get_previous_active_state()!=flip_state:
		#state = States.JUMP
		if Input.is_action_just_released("jump") and velocity.y<movement_data.jump_velocity/2:
			
			velocity.y = movement_data.jump_velocity/2
			#state = States.JUMP
			state_machine.dispatch(&"start_jumping")
		if Input.is_action_just_pressed("jump") and double_jump_flag == true and just_wall_jump == false:
			
			velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.acceleration*10 * delta)
			velocity.y = movement_data.jump_velocity *0.8
			double_jump_flag = false
			#state = States.JUMP
			state_machine.dispatch(&"start_jumping")

#breaking out of a flip. Test without timer later
func break_out():
	
	if Input.is_action_just_pressed("jump") and not Input.is_action_pressed("sprint"):
		
		state_machine.dispatch(&"jump_out")
		jump_out_signal.emit(30)
	elif Input.is_action_just_pressed("attack"):
		attack_combo="Flip_Attack"
		state_machine.dispatch(&"flip_attack")
		jump_out(15)
		
		
#jump out of flip
func jump_out(jumpout_vel : float):
	knockback.x=jumpout_vel
	print(knockback.x)
	print(vector_away.x)
	var jump_left
	if global_position.x - target.global_position.x > 0:
		jump_left=true
	else:
		jump_left=false
	if not jump_left:
		knockback.x = knockback.x*-1
	else:
		knockback.x=knockback.x
	velocity.y=movement_data.jump_velocity*0.8
	hit_stop.hit_stop(1,0)
	set_collision_mask_value(15, true)


func handle_wall_jump(wall_hold, delta):
	if not is_on_wall_only(): return
	if not Input.is_action_pressed("sprint"): return
	var wall_normal = get_wall_normal()

	
	if Input.is_action_just_pressed("walk_left") and wall_normal == Vector2.LEFT and wall_hold == true:
		#state = States.WALL_STICK
		state_machine.dispatch(&"stick_to_wall")
		velocity.x =0
		velocity.y = 0
		gravity = 0
		
	elif Input.is_action_just_pressed("walk_right") or Input.is_action_just_pressed("jump") or Input.is_action_just_released("sprint"):
		state_machine.dispatch(&"jump_off_wall")
		velocity.x = move_toward(velocity.x, movement_data.speed * wall_normal.x * 1.5, movement_data.acceleration*10 * delta)
		velocity.y = movement_data.jump_velocity
		just_wall_jump = true
		
		
		
		
	if Input.is_action_just_pressed("walk_right") and wall_normal == Vector2.RIGHT and wall_hold == true:
		state_machine.dispatch(&"stick_to_wall")
		velocity.x =0
		velocity.y = 0
		gravity = 0
	
	elif Input.is_action_just_pressed("walk_left") or Input.is_action_just_pressed("jump")  or Input.is_action_just_released("sprint"):
		state_machine.dispatch(&"jump_off_wall")
		velocity.x = move_toward(velocity.x, movement_data.speed * wall_normal.x * 1.5, movement_data.acceleration*10 * delta)
		velocity.y = movement_data.jump_velocity
		just_wall_jump = true
		
		
	
		
	if wall_hold == true:
		velocity.x =0
		velocity.y = 0
		gravity = 0
		
	else:
		gravity = 980



func apply_air_resistance(input_axis, delta):
	if input_axis == 0 and not is_on_floor() and not s_atk:
		velocity.x = move_toward(velocity.x, 0 , movement_data.air_resistance * delta)
# Get the input direction and handle the movement/deceleration.
func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)
		
# Apply friction after dtopping.
func handle_acceleration(input_axis, delta):
	if not is_on_floor(): return
	if s_atk: return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.acceleration * delta)
		if state_machine.get_active_state()==idle:
			state_machine.dispatch(&"start_walking")

# Movement for cutscenes		
func cutscene_acceleration(dir, delta):
	if dir!=0:
		velocity.x = move_toward(velocity.x, (movement_data.speed/3) * dir, movement_data.acceleration * delta)
	else:
		velocity.x=0
		
		
func set_movement_data(value : int) -> void:
	match value:
		0:
			movement_data = load("res://DefaultMovementData.tres")
		1:
			movement_data = load("res://SlowMovementData.tres")
		2:
			movement_data = load("res://FasterMovementData.tres")
#

func handle_air_acceleration(input_axis, delta):
	if is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.air_acceleration * delta)

func update_animation(input_axis):
	if Input.is_action_pressed("up"):
		if Input.is_action_pressed("walk_right"):
			parry_box.rotation=-(PI/4)
		elif Input.is_action_pressed("walk_left"):
			parry_box.rotation=(PI/4)
		else:
			if parry_box.scale.x<0:
				parry_box.rotation=(PI/2)
			else:
				parry_box.rotation=-(PI/2)
	elif Input.is_action_just_released("up") :
		parry_box.rotation=0

	
	
	if combat_states.get_active_state()!=locked:
		if input_axis != 0:
		
			if input_axis<0:
				animated_sprite_2d.scale.x=-1
				
			else:
				animated_sprite_2d.scale.x=1
				
					
			if state_machine.get_previous_active_state()!=attack_state and s_atk==false:
				#state = States.WALKING
				
				if Input.is_action_pressed("sprint"):
					if combat_states.get_active_state()!=locked:
						walk_anim="run"
						state_machine.dispatch(&"start_sprinting")
					else:
						state_machine.dispatch(&"start_walking")
					movement_data = load("res://FasterMovementData.tres")
				elif Input.is_action_just_released("sprint"):
					movement_data = load("res://DefaultMovementData.tres")
					walk_anim="walk"
					state_machine.dispatch(&"start_walking")
				else:
					walk_anim="walk"
					state_machine.dispatch(&"start_walking")
					
	else:
		if not target_right:
			animated_sprite_2d.scale.x=-1
			if input_axis>0:
				walk_anim="walk_back"
			else:
				walk_anim="walk"
		else:
			animated_sprite_2d.scale.x=1
			if input_axis>0:
				walk_anim="walk"
			else:
				walk_anim="walk_back"
		if (state_machine.get_previous_active_state()!=attack_state and s_atk==false) and input_axis!=0:
			state_machine.dispatch(&"start_walking")
		if Input.is_action_pressed("sprint"):
			movement_data = load("res://FasterMovementData.tres")
		elif Input.is_action_just_released("sprint"):
			movement_data = load("res://DefaultMovementData.tres")
	if (Input.is_action_just_released("walk_left") or Input.is_action_just_released("walk_right")) and input_axis==0:
		#state = States.IDLE
		state_machine.dispatch(&"return_to_idle")
		
	if is_on_floor():
		jumping=false
		if state_machine.get_previous_active_state()==jump_state:
			falling=false
			state_machine.dispatch(&"return_to_idle")
	
		
		
func attack_animate():


	if Input.is_action_just_pressed("attack") and attack_timer.paused==false:
		if state_machine.get_active_state()==parry_success_state:
			return
		attack_timer.start()
		if state_machine.get_active_state()!=attack_state:
			attack_timer.paused=true
			
		if counter_flag:
			attack_combo = "Attack_Counter"
			hit_box.set_damage(3)
			hit_sound = hit1
			AudioStreamManager.play(swing1)
		elif target_below:
			attack_combo = "Attack_Down"
			hit_box.set_damage(2)
			hit_sound = hit1
			AudioStreamManager.play(swing1)
			velocity.y=movement_data.jump_velocity/2
		else:
			hit_box.set_damage(1)
			if not attack_timer.is_stopped():
				if atk_chain == 0:
					#attack_combo = "Attack"
					#hit_sound = hit1
					AudioStreamManager.play(swing1)

				elif atk_chain == 1 and sp_atk_chn<1:
					#attack_combo = "Attack_2"
					#hit_sound = hit2
					AudioStreamManager.play(swing2)
				
				elif atk_chain == 2:
					#attack_combo = "Attack_3"
					#hit_sound = hit3
					AudioStreamManager.play(swing3)
				elif sp_atk_chn>=1:
					attack_combo = "Attack_Chain"
					hit_sound = hit2
					AudioStreamManager.play(swing2)
		
		
		#set_state(state, States.ATTACK)
		if state_machine.get_active_state()==attack_state:
			if atk_1_resume:
				attack_state.dispatch(&"combo_resume")
			elif atk_2_resume:
				attack_state.dispatch(&"combo_resume_2")
			else:
				attack_state.dispatch(&"next_attack")
		else:
			state_machine.dispatch(&"start_attack")
		#await anim_player.animation_finished
		#attack_timer.paused=false
		
		
func dash_attack_enter():
	if state_machine.get_active_state()==attack_state:
		return
	attack_timer.paused=true
	attack_state.dispatch(&"dash_attack")
	state_machine.dispatch(&"dash_attack")
	#attack_combo = "Attack_Dash"
	#hit_sound = hit1
	#AudioStreamManager.play(swing1)
	##set_state(state, States.ATTACK)

func sp_atk():
	if s_atk:
		return
	if state_machine.get_previous_active_state()==flip_state:
		shotty.look_at(target.global_position)
	else:
		shotty.look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("special_attack") and state_machine.get_active_state()!=parry_success_state and state_machine.get_active_state()!=special_attack:
		
		if state_machine.get_active_state()==attack_state:
			if attack_timer.is_stopped():
				attack_timer.start(1)
				attack_timer.paused=false
			
			attack_state.dispatch(&"special_combo")
		else:
			
			if attack_timer.is_stopped():
				attack_timer.start(1)
				attack_timer.paused=false
			
			state_machine.dispatch(&"special_attack")
				
			
			
		#if combo_state==ComboStates.SPC_ATK_BACK:
			#
			#sp_atk_combo="shotgun_attack_fast"
		#else:
			#if atk_chain==0:
				#if sp_atk_chn == 0 and (not attack_timer.is_stopped()):
					#sp_atk_combo="shotgun_attack"
					#if state_machine.get_previous_active_state()!=hit:
						#AudioStreamManager.play(shotgun_fire)
					#sp_atk_dmg=1
#
				#elif sp_atk_chn == 1 and (not attack_timer.is_stopped()):
					#sp_atk_combo="shotgun_attack"
#
					#if state_machine.get_previous_active_state()!=hit:
						#AudioStreamManager.play(shotgun_fire)
					#sp_atk_dmg=1
#
				#elif sp_atk_chn == 2 and (not attack_timer.is_stopped()):
#
					#if state_machine.get_previous_active_state()!=hit:
						#AudioStreamManager.play(reload)
					#sp_atk_combo="shotgun_attack"
					#sp_atk_dmg=2
					#
			#else:
				#sp_atk_combo="shotgun_attack_fast"

		#set_state(state, States.SPECIAL_ATTACK)
		attack_timer.paused = false



func parry():
	
	if Input.is_action_just_pressed("parry") and state_machine.get_active_state()!=parry_success_state:
		parry_timer.start()
		parry_stance=true
		#set_state(state, States.PARRY)
		state_machine.dispatch(&"start_parry")
		pb_rot.disabled=false


	elif Input.is_action_just_released("parry") and state_machine.get_active_state()!=parry_success_state:
		parry_timer.stop()
		parry_stance=false
		state_machine.dispatch(&"return_to_idle")
		#anim_player.stop()
		
	
	#parry interactions
	if parry_stance==true:
		velocity.x=0
		velocity.y=0

		
			
## DODGE NEEDS WORK!!!
func dodge(input_axis):

	if Input.is_action_just_pressed("Dodge"):
		dodge_timer.start()
		if not is_on_floor():
			velocity.y=0
		
		if input_axis == 0:
			dodge_anim_run=dodge_anim
			velocity.x=0
			state_machine.dispatch(&"start_dodge")
		else:
			
			dodge_anim_run=dodge_anim+"_roll"
			state_machine.dispatch(&"start_dodge")
			velocity.x=movement_data.dodge_speed*input_axis

		
	
	
	if (dodge_timer.is_stopped()) and state_machine.get_previous_active_state()==dodge_back:
		
		#dodge_state=false
		dodge_timer.stop()
		#state=States.IDLE
		state_machine.dispatch(&"return_to_idle")
	

func lockon():
	var target_dist : Vector2 = Vector2.ZERO
	
	if Input.is_action_just_pressed("lockon"):
		enemies = get_tree().get_nodes_in_group("Enemy")
		if enemies.is_empty():
			return
		
		Events.unlock_from.emit()
		find_closest_enemy()
		
		

		if not target.on_screen.is_on_screen() or target.state_machine.get_active_state()==target.death:
			
			target=null
		else:
			target.target_lock()
		
	if target == null:
		
		target_string_test="NONE"
		combat_states.dispatch(&"unlocking")
	else:
		
		target_dist=abs(global_position-target.global_position)
		if (target.state_machine.get_active_state()==target.death):
			combat_states.dispatch(&"unlocking")
			return
		
		combat_states.dispatch(&"locking_on")
		var direction_to_target : Vector2 = Vector2(target.position.x, target.position.y) - global_position
		
		var arc_vector = Vector2(position-Vector2(target.position)).normalized()
		target_direction = position.direction_to(target.position)
		
		#raycast from pointing away NEEDS WORK
		var dir_away_from_target : Vector2 = (Vector2(target.position.x, target.position.y) - target_testing.position)
		
		target_locking.look_at(dir_away_from_target)
		vector_away=-((target_testing.to_global(target_testing.target_position) - target_testing.to_global(Vector2.ZERO)).normalized())
		
		if state_machine.get_active_state()!=flip_state:
			if arc_vector<Vector2.RIGHT and Vector2.UP<arc_vector:
				
				#"on right")
				target_right = false
				
			elif arc_vector>Vector2.LEFT and Vector2.UP>arc_vector:
				#"on left")
				target_right = true
			
func find_closest_enemy():
	enemies.clear()
	
	enemies = get_tree().get_nodes_in_group("Enemy")
	
	if enemies.is_empty():
		return
		
	
	var closest_enemy = enemies[0]
	
	for enemy in enemies:
		if is_instance_valid(enemy):
			if (enemy.global_position.distance_to(global_position) < closest_enemy.global_position.distance_to(global_position))\
			and (enemy.state_machine.get_active_state()!=enemy.death):
				
				closest_enemy=enemy

			else:
				continue
		else:
			continue
			
	target=closest_enemy
	
	
	
func get_target_info():
	if target==null:
		return
	else:
		target_size_x = target.get_width()
		target_size_y = target.get_height()
		target_top = target.global_position.y-(target_size_y/2-5)
		target_left_edge=target.global_position.x-(target_size_x/2)
		target_right_edge=target.global_position.x+(target_size_x/2)
		
		if target_size_y > collision_shape_2d.get_shape().size.y*1.5:
			high_target=true
		else:
			high_target=false

func locked_combat():
	if target==null:
		return
	else:
		var direction_to_target : Vector2 = Vector2(target.global_position.x, target.global_position.y) - global_position
		
		if target_right:
			var dist_to_edge=round(abs(global_position.x-target_right_edge))
			
		else:
			var dist_to_edge=round(abs(global_position.x-target_left_edge))
			
		if abs(direction_to_target.x) >(50+target_size_x) or abs(direction_to_target.y)>(10+target_size_y):
			pass
		else:
			if Input.is_action_just_pressed("jump") and Input.is_action_pressed("sprint"):
				#set_state(state, States.FLIP)
				flip.emit()

func enter_door() -> void:
	if in_door_way:
		if Input.is_action_just_pressed("up"):
			prev_room=cur_room
			cur_room=next_room
			Global.game_controller.change_2d_scene(next_room, false, false, entry_pos, "fade_to_black_quick", "fade_from_black_quick")
			entry_pos=prev_starting_pos

func climb_stairs() -> void:
	if Input.is_action_pressed("up") and stairs_detected==false:
		set_collision_mask_value(20, true)
		stairs_release=false
	elif Input.is_action_just_released("up"):
		if stairs_detected:
			stairs_release=true
		else:
			set_collision_mask_value(20, false)

func _on_hazard_detector_area_entered(area):
	if area.is_in_group("hazard"):
		global_position=starting_position
		
		health.health -= 1
		
	elif area.is_in_group("Enemy"):
		hit_stop.hit_stop(0.05, 0.1)
		knockback.x = input_dir.x * knockback.x *0.25

	
	
##State machine for animations currently
##func set_state(current_state, new_state: int) -> void:
	###current_state, new_state)
##
	##if(current_state == new_state):
		###"no change")
		##return
	###else:
		###current_state, new_state)
		####"changing")
	##
	##if current_state==States.JUMP:
		##air_atk=true
		###if not is_on_floor():
			###return
		###air_atk)
	##if current_state == States.PARRY and parry_stance==true:
		##pass
	##
	##prev_state=current_state
	##state=new_state
	##match new_state:
		##States.ATTACK:
			###cur_state="ATTACK"
			##anim_player.speed_scale=1.5
			##anim_player.play(attack_combo)
			##if air_atk==true:
			##
				##velocity=Vector2.ZERO
				##gravity=0
				##
		##States.SPECIAL_ATTACK:
			##anim_player.speed_scale=1.5
			###sp_atk_chn+=1
			##if sp_atk_chn==2:
				##anim_player.play("shotgun_finish")
				##await anim_player.animation_finished
				##sp_atk_chn=0
			##anim_player.play(sp_atk_combo)
			##if current_state==States.FLIP:
				##hitstop_time_left=hit_stop.get_time_left()
				##print(hitstop_time_left)
				##hit_stop.hit_stop(.1,.1)
					##
			###if not is_on_floor():
				###velocity=Vector2.ZERO
				###gravity=0
		##States.IDLE:
			##anim_player.speed_scale=1
			##anim_player.play("idle")
			###"playing idle")
			##movement_data.friction=1000
			##s_atk=false
			##counter_box_collision.disabled=true
			##hb_collision.disabled=true
			##air_atk=false
			##flipped_over=false
		##States.WALKING:
			##anim_player.speed_scale=1
			###if jumping:
				###pass
			###else:
				###anim_player.play("walk")
			##anim_player.play("walk")
		##States.JUMP:
			##jumping=true
			###if falling==false:
				###anim_player.play("jump")
			###else:
				###pass
			##cur_state="JUMP"
			##anim_player.play("jump")
		##States.DODGE:
			##hurt_box_detect.disabled=true
			##counter_box_collision.disabled=false
			##anim_player.speed_scale=1
			##anim_player.play(dodge_anim_run)
			##set_collision_mask_value(15, false)
			##velocity.y=0
			###velocity.x=100 * move_axis
		##States.PARRY:
			##hurt_box_detect.disabled=true			
			##anim_player.play("Parry")
		##States.FLIP:
			##anim_player.play("flip")
			##cur_state="Flipping"
			##set_collision_mask_value(15, false)
			##high_target_jump_height = (global_position.y-collision_shape_2d.get_shape().size.y)
			##if current_state==States.SPECIAL_ATTACK:
				##hit_stop.hit_stop(.5, (hitstop_time_left-0.1))
		##States.SPRINTING:
			##anim_player.speed_scale=1
			###if jumping:
				###pass
			###else:
				###anim_player.play("run")
			##anim_player.play("run")
		##States.HIT:
			##anim_player.play("hit")
			##hurt_box_detect.disabled=true
		##States.STAGGERED:
			##anim_player.play("staggered")
			##knockback=Vector2.ZERO
	##if state != States.DODGE:
		##hurt_box_detect.disabled=false
			##
	##
				##
			##
	##if state!=States.PARRY:
		##pb_rot.disabled=true
#
func get_state() -> String:
	return cur_state
func get_state_enum() -> LimboState:
	return state_machine.get_active_state()
#
func get_health() -> int:
	return health.health
func get_max_health() -> int:
	return health.max_health

func _on_health_health_depleted():
	Events.game_over.emit()

	
#knockbacks
#func _on_hurt_box_knockback(hitbox):
	##kb_dir=global_position.direction_to(hitbox.global_position)
	##"knockback")
	##kb_dir=round(kb_dir)
	##kb_dir.x, " ", knockback)

func _on_hurt_box_got_hit(_hitbox):
	var hb_dir_right
	if not hit_timer.is_stopped():
		return
	if _hitbox.global_position.x-global_position.x>0 :
		hb_dir_right=true
	else:
		hb_dir_right=false
	if state_machine.get_active_state()==parry_state:
		return
	if _hitbox.is_in_group("regular_enemy_hb"):
		if hit_timer.is_stopped():
			AudioStreamManager.play(SoundFx.PUNCH_DESIGNED_HEAVY_12)
		player_hit.emitting=true
		player_hit.restart()
		hurt_box_detect.disabled=true
		hit_timer.start(0.2)
		stagger.stagger-=1
		if state_machine.get_previous_active_state()!=flip_state:
			if parry_success_state.get_previous_active_state()==heavy_riposte:
				if target_right:
					knockback.x=400
				else:
					knockback.x=-400
			else:
				if hb_dir_right:
					knockback.x=-15
				else:
					knockback.x=15
			state_machine.dispatch(&"got_hit")
			
	elif hitbox.is_in_group("heavy_hitbox"):
		knockback.x = -400
		kb_dir=global_position.direction_to(_hitbox.global_position)
		#"knockback")
		kb_dir=round(kb_dir)
		#kb_dir.x, " ", knockback)
		knockback.x = kb_dir.x * knockback.x
		velocity.y=movement_data.jump_velocity/2
		#velocity.x = movement_data.speed + knockback.x
		health.set_temporary_immortality(0.2)
	else:
		set_collision_mask_value(16384, false)
		knockback.x = -35
		kb_dir=global_position.direction_to(_hitbox.global_position)
		#"knockback")
		kb_dir=round(kb_dir)
		#kb_dir.x, " ", knockback)
		knockback.x = kb_dir.x * knockback.x
		velocity.y=movement_data.jump_velocity/2
		#velocity.x = movement_data.speed + knockback.x
		health.set_temporary_immortality(0.2)

func _on_hit_timer_timeout() -> void:
	hurt_box_detect.disabled=false
	if state_machine.get_previous_active_state()!=flip_state:
		state_machine.dispatch(&"return_to_idle")
	player_hit.emitting=false

func _on_parry_box_parried_success() -> void:
	state_machine.dispatch(&"parry_successful")
	clash_power.increase_clash()
	clash_visual.emitting=true
	
func _on_hurt_box_area_entered(area):
	if area.is_in_group("bullet"):
		hit_stop.hit_stop(0.05, 0.1)
		knockback.x = -10
		kb_dir=global_position.direction_to(area.global_position)
		#"knockback")
		kb_dir=round(kb_dir)
		#kb_dir.x, " ", knockback)
		knockback.x = kb_dir.x * knockback.x
		knockback.y=-5
		#velocity.x = movement_data.speed + knockback.x
		health.health -= 1
		health.set_temporary_immortality(0.2)
		if state_machine.get_previous_active_state()==flip_state:
			state_machine.dispatch(&"return_to_idle")
		if clash_power.clash_power>1:
			health.health-=clash_power.clash_power
			stagger.stagger-=clash_power.clash_power
			clash_power.reset_clash()
			clash_timer.stop()
			if clash_power.clash_power==clash_power.clash_max:
				hit_stop.hit_stop(.3,.5)
		
	if area.is_in_group("Hearts"):
		health.health+=1
		
	elif area.is_in_group("Enemy"):
		pass
	

#Setting starting positions for level starts and checkpoints
func get_start_pos():
	return starting_position

func set_start_pos(checkpoint_position):
	starting_position=checkpoint_position



func _on_animation_player_animation_finished(anim_name):
	cutscene_handler.anim_count_up()
	if state_machine.get_active_state()==attack_state:
		#"attack finished")
		hit_success=false
		if anim_name=="Attack_Counter":
			counter_flag=false
			return
		elif anim_name=="Attack_Chain":
			state_machine.dispatch(&"return_to_idle")
			sp_atk_chn=0
			atk_chain=0
			attack_timer.start(0.2)
			combo_state=ComboStates.SPC_ATK_BACK
			return
		#if atk_chain < 2:
			#atk_chain += 1
		#elif atk_chain >=2:
			#atk_chain = 0
			#attack_combo = "Attack"
		elif anim_name=="Attack_Dash":
			attack_timer.start(.2)
			attack_timer.paused=false
			anim_player.play("landed")
		else:
			attack_timer.start(1)
			attack_timer.paused=false
			if input_axis!=0:
				anim_player.play(walk_anim)
			else:
				anim_player.play("idle")
			
		if state_machine.get_previous_active_state()==flip_state:
			state_machine.dispatch(&"jump_out")
			
		#else:
			#state_machine.dispatch(&"return_to_idle")
		hb_collision.disabled=true
		
	#elif state==States.SPECIAL_ATTACK:
		#if prev_state==States.FLIP:
			#if anim_name=="shotgun_attack":
				##flip.emit()
				#
				##set_state(state, States.FLIP)
				#s_atk=false
		#else:
			#if anim_name=="shotgun_attack":
				#if sp_atk_chn < 2:
				#
					#sp_atk_chn += 1
				##"Attack Chain")
				#elif sp_atk_chn >=2:
					#sp_atk_chn = 0
				##"special finished")
				#s_atk=false
				##state=States.IDLE
				#if falling:
					#velocity.y=vel_y
				#state_machine.dispatch(&"return_to_idle")
			#elif anim_name=="shotgun_finish":
				#AudioStreamManager.play(shotgun_fire)
				##state=States.IDLE
				#s_atk=false
				#state_machine.dispatch(&"return_to_idle")
			#elif anim_name=="shotgun_attack_fast":
				##AudioStreamManager.play(shotgun_fire)
				#sp_atk_chn += 1
				##state=States.IDLE
				#s_atk=false
				#state_machine.dispatch(&"return_to_idle")
	#elif state==States.JUMP:
		#if anim_name=="jump":
			#falling=true
	elif anim_name=="staggered":
		state_machine.dispatch(&"return_to_idle")
		stagger.stagger=stagger.get_max_stagger()
	#
	elif anim_name=="dodge_roll":
		
		velocity.x=0
		counter_box_collision.disabled=false
		set_collision_mask_value(15, true)
	elif anim_name=="dodge":
		
		counter_box_collision.disabled=false
	elif anim_name=="flip":
		
		anim_player.speed_scale=1
		state_machine.dispatch(&"landed")
	#
	#
	#
	#else:
		#pass

func _on_attack_timer_timeout():
	if state_machine.get_active_state()==parry_success_state:
		return
	atk_chain = 0
	attack_combo = "Attack"
	
	if input_axis!=0:
		state_machine.dispatch(&"start_walking")
	else:
		state_machine.dispatch(&"return_to_idle")
	#attack_state.dispatch(&"reset_combo")
	sp_atk_chn = 0
	combo_state=ComboStates.ATK_1
	atk_1_resume=false
	atk_2_resume=false

func load_player_data():
	var file = FileAccess.open("user://player_data/stats/player_stats.txt", FileAccess.READ)
	#if file.file_exists("user://player_data/stats/player_stats.txt"):
		#while file.is_open():
			#var content = file.get_line()
			#var stat : String = content.get_slice(":", 0)
			#var stat_val : int = int(content.get_slice(":", 1))
			#
			#if stat != null:
				#match stat:
					#"health":
						#health.set_health(100)
					#"max_health":
						#health.set_max_health(100)
					#"max_stagger":
						#pass
					#"ammo":
						#ammo=stat_val
						#
			#if file.eof_reached():
				#break
		#file.close()
	health.health = GlobalSaveData.current_save.player.health
	health.max_health = GlobalSaveData.current_save.player.max_health
	stagger.stagger = GlobalSaveData.current_save.player.stagger
	stagger.max_stagger = GlobalSaveData.current_save.player.max_stagger
	
	
	#else:
		#print("file not found")
		
	


func save_player_data():
	#var file = FileAccess.open("user://player_data/stats/player_stats.txt", FileAccess.READ_WRITE)
	#if file.file_exists("user://player_data/stats/player_stats.txt"):
		#var stat : String = str("health: ", health.get_health())
		#file.store_string(stat)
		#file.store_string("\n")
		#stat = str("max_health: ", health.get_max_health())
		#file.store_string(stat)
		#file.store_string("\n")
		#file.close()
	#else:
		#print("file not found")
	GlobalSaveData.current_save.player.health=health.health
	GlobalSaveData.current_save.player.max_health=health.max_health
	GlobalSaveData.current_save.player.stagger=stagger.stagger
	GlobalSaveData.current_save.player.max_stagger=stagger.max_tagger
	GlobalSaveData.save_game()

func _on_parry_timer_timeout():
	parry_timer.stop()
	parry_stance=false
	#state=States.IDLE
	state_machine.dispatch(&"return_to_idle")
	
	#anim_player.stop()
	
func parry_success():
	parry_timer.stop()
	anim_player.play("Parry_Success")
	
	AudioStreamManager.play(parry_sfx)
	await anim_player.animation_finished
	#anim_player.stop()



func _on_hit_box_area_entered(_area):
	hit_sound=hit1
	AudioStreamManager.play(hit_sound)
	hb_collision.disabled


func _on_hit_box_body_entered(body):
	if body.is_in_group("Enemy") and combat_states.get_active_state()==unlocked:
		Events.unlock_from.emit()
		target_string_test=str(body.name)
		target = body
		combat_state=CombatStates.LOCKED
		combat_states.dispatch(&"locking_on")
		if clash_power.clash_power>1:
			stagger.stagger+=clash_power.clash_power
			clash_power.reset_clash()
			clash_timer.stop()
			if clash_power.clash_power==clash_power.clash_max:
				hit_stop.hit_stop(.3,.5)
	
	
func flip_over():
	
	flip_speed=movement_data.speed * 80
	
	state_machine.dispatch(&"start_flip")
	#state=States.FLIP
#
func flipping(delta):
#	variables set and declared
	target_pos_y=(target.global_position.y)
	var pos_above_y=target.global_position.y-global_position.y
	target_pos_x=(target.global_position.x)
	var pos_above_x=target.global_position.x-global_position.x
	#print(global_position)
#	Jumping before flipping over
	if not flipped_over:
		health.immortality=true
		hurt_box_detect.disabled=true
		#position.y, " ",target_size_y+target.position.y)
		if global_position.y>target_top-15 and not high_target:
			if target_right:
				if global_position<Vector2((target_left_edge-15),(target_top-25)):
					global_position=lerp(global_position, Vector2((target_left_edge-5),(target_top-40)), delta*3)
				else:
					velocity.y=movement_data.jump_velocity
			else:
				if global_position>Vector2((target_right_edge+15),(target_top-25)):
					global_position=lerp(global_position, Vector2((target_right_edge+5),(target_top-40)), delta*3)
				else:
					velocity.y=movement_data.jump_velocity
							
		elif global_position.y>(high_target_jump_height-15) and high_target:
			if target_right:
				if global_position<Vector2((target_left_edge),(high_target_jump_height)):
					global_position=lerp(global_position, Vector2((target_left_edge-5),(high_target_jump_height*0.7)), delta*3)
				else:
					velocity.y=movement_data.jump_velocity
			else:
				
				if global_position>Vector2((target_right_edge),(high_target_jump_height)):
					global_position=lerp(global_position, Vector2((target_right_edge+5),(high_target_jump_height*0.7)), delta*3)
				else:
					velocity.y=movement_data.jump_velocity

		else:
			flipped_over=true
			hit_stop.hit_stop(.2, .5)

#	flipping over
	else:
		health.immortality=false
		hurt_box_detect.disabled=false
		flipped_over=true
		if not high_target:
			if not target_right:
				movement = target_direction.rotated(CLOCKWISE)
				
				#"flip_right")
			else:
				movement = target_direction.rotated(COUNTER_CLOCKWISE)
				#"flip_left"
			
			if global_position.y<target_top:
				velocity = movement * flip_speed * delta
				
			else:
				velocity.y += gravity * movement_data.gravity_scale * delta
		else:
			hit_stop.hit_stop(.1, .5)
			jump_out_timer.start(0.05)
			velocity.y=0
		


func _on_jump_out_timer_timeout():
	jump_out(200)
	



func atk_state_debug():
	match combo_state:
		ComboStates.ATK_1:
			atk_state="AKT_1"
		ComboStates.SPC_ATK_BACK:
			atk_state="SPC_ATK_BACK"
			

func _on_counter_box_area_entered(area):
	if area.is_in_group("bullet"):
		counter_flag = true
		counter_timer.start()
		clash_power.clash_power += 1
		
	elif area.is_in_group("regular_enemy_hb"):
		print("enemy dodge")
		state_machine.dispatch(&"dodge_successful")
		clash_power.clash_power += 1
		
		
	clash_power.increase_clash()
	clash_visual.emitting=true
	clash_timer.start()
		


func _on_counter_timer_timeout():
	counter_flag = false


func _on_hazard_detector_body_entered(body):
	if body.is_in_group("Enemy"):
		if (position.y-body.position.y)<0:
			target_below=true
		else:
			print("enemy above")


func _on_hazard_detector_body_exited(body):
	if body.is_in_group("Enemy"):
		#"leaving enemy")
		target_below=false


func _on_animation_player_animation_started(anim_name):
	if anim_name=="Attack_Chain":
		if face_right:
			forward_thrust.x=200
		else:
			forward_thrust.x=-200
		velocity.x = forward_thrust.x
	elif anim_name=="shotgun_attack_fast":
		AudioStreamManager.play(shotgun_fire)
		if combo_state==ComboStates.SPC_ATK_BACK:
			knockback.y=-100
			if face_right:
				knockback.x=-250
			else:
				knockback.x=250
			velocity.x = knockback.x
			velocity.y = knockback.y
	elif anim_name=="shotgun_attack":
		vel_y=velocity.y
		#s_atk=true

func _on_hurt_box_received_damage(damage: int) -> void:
	hit_stop.hit_stop(0.05, 0.1)
	Events.camera_shake.emit(2,20)
	if state_machine.get_active_state()==flip_state:
		#print("countered! your moves are weak!")
		if target_right:
			knockback.x=400
		else:
			knockback.x=-400
		#velocity.x = movement_data.speed + knockback.x
		state_machine.dispatch(&"got_hit")
	elif state_machine.get_active_state()==parry_success_state:
		state_machine.dispatch(&"got_hit")
		stagger.stagger-=3
		

func _on_stagger_staggered() -> void:
	knockback.x=0
	velocity=Vector2.ZERO
	state_machine.dispatch(&"got_staggered")
	Events.camera_shake.emit(2,15)
	
func _on_hit_box_parried() -> void:
	anim_player.play("parried")
	hb_collision.disabled=true
	if target_right:
		knockback.x=-40
	else:
		knockback.x=40
	Events.enemy_parried.emit()
	
	#velocity.x = movement_data.speed + knockback.x

#####################
##Cutscene Functions#
#####################
#
#
func set_path_speed(speed : int) -> void:
	path_speed=speed
	#print(path_speed)
func start_path(speed : int):
	set_path_start(true)
	set_path_speed(speed)
	#print(speed)
func set_path_start(value) -> void:
	path_start=value
#
################
##QTE Functions#
################

func qte_input():
	if Input.is_action_just_pressed("attack"):
		attack_qte.emit()
		hit_stop.end_hit_stop()
	elif Input.is_action_just_pressed("Dodge"):
		dodge_qte.emit()
		hit_stop.end_hit_stop()
	elif Input.is_action_just_pressed("parry"):
		block_qte.emit()
		hit_stop.end_hit_stop()
	elif Input.is_action_just_pressed("special_attack"):
		special_atk_qte.emit()
		hit_stop.end_hit_stop()
	else:
		pass
		
		
func _on_hit_stop_hit_stop_finished() -> void:
	if qte_handler.actor_control_active:
		no_input_qte.emit()
	else:
		pass



func _on_idle_entered() -> void:
	anim_player.play("idle")


func _on_state_machine_active_state_changed(current: LimboState, _previous: LimboState) -> void:
	#label.text=str(current.name)

	if current==dodge_state:
		
		if attack_state.get_active_state()==attack_1:
			atk_1_resume=true
		elif attack_state.get_active_state()==attack_2:
			atk_2_resume=true
	#FOR DEBUGGING TO BE REMOVED
	match current:
		attack_state:
			cur_state="ATTACK"
		special_attack:
			cur_state="SPECIAL_ATTACK"
		idle:
			cur_state="IDLE"
		walking:
			cur_state="WALKING"
		jumping:
			cur_state="JUMP"
		dodge_state:
			cur_state="DODGE"
		wall_stick:
			cur_state="WALL STICK"
		sprint:
			cur_state = "SPRINTING"
		parry_state:
			cur_state = "PARRY"
		flip_state:
			cur_state = "FLIP"
		parry_success_state:
			cur_state= "PARRY SUCCESS"
		recovery:
			if _previous==hit:
				recovery.recover_anim="hit_recover"
			elif _previous==staggered:
				recovery.recover_anim="stagger_recover"
	#match _previous:
		#attack_state:
			#cur_state="ATTACK"
		#special_attack:
			#cur_state="SPECIAL_ATTACK"
		#idle:
			#cur_state="IDLE"
		#walking:
			#cur_state="WALKING"
		#jumping:
			#cur_state="JUMP"
		#dodge_state:
			#cur_state="DODGE"
		#wall_stick:
			#cur_state="WALL STICK"
		#sprint:
			#cur_state = "SPRINTING"
		#parry_state:
			#cur_state = "PARRY"
		#flip_state:
			#cur_state = "FLIP"
		#parry_success_state:
			#cur_state= "PARRY SUCCESS"

func _on_attack_state_active_state_changed(current: LimboState, previous: LimboState) -> void:
	if current==special_combo:
		if previous==attack_1:
			atk_1_resume=true
		elif previous==attack_2:
			atk_2_resume=true
	if previous==special_combo:
		atk_1_resume=false
		atk_2_resume=false
	#if current==attack_1:
		#atk_1_resume=true
	#elif current==attack_2:
		#atk_1_resume=true


func _on_combat_states_active_state_changed(current: LimboState, previous: LimboState) -> void:
	pass


func _on_clash_timer_timeout() -> void:
	clash_power.reset_clash()
	clash_visual.emitting=false
	


func _on_stars_detector_body_entered(body: Node2D) -> void:
	stairs_detected=true

func _on_stars_detector_body_exited(body: Node2D) -> void:
	stairs_detected=false
	if stairs_release:
		set_collision_mask_value(20, false)
		
