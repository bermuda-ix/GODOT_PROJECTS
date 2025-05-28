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

@export var movement_data : PlayerMovementData
@export var health: Health
@export var hitbox: HitBox
@export var ammo : int = 0
@export var TARGET_LOCK = preload("res://Component/effects/target_lock.tscn")

#Base FSM
enum States {IDLE, WALKING, JUMP, ATTACK, SPECIAL_ATTACK, WALL_STICK, PARRY, DODGE, SPRINTING,
FLIP,THRUST, HIT, STAGGERED}
#FSM for lock on
enum CombatStates {LOCKED, UNLOCKED}
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
var input_dir=Input.get_axis("walk_left","walk_right")
#dodge dir
var dodge_state = false
var dodge_v = 0.0
var falling : bool = false
var jumping : bool = false

var cur_state = "IDLE"
var previous = "IDLE"
var atk_state="ATK_1"

#Animation var
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var anim_player = $AnimationPlayer

@onready var speech: Label = $Speech
#Cutscenes
@onready var anim_count : int = 0
@onready var cutscene_handler: CutsceneHandler = $CutsceneHandler




@onready var path_speed : int = 0 : set=set_path_speed
@onready var path_start : bool = false : set=set_path_start
@export var camera_pos : camera_position
#@onready var camera_2d: Camera2D = $Camera2D


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
@onready var pb_rot = $ParryBox/PBRot
@onready var parry_box = $ParryBox
@onready var counter_box_collision = $CounterBox/CounterBoxCollision
@onready var stagger: Stagger = $Stagger

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


	
func _process(delta):
	knockback=clamp(knockback, Vector2(-400, -400), Vector2(400, 400) )
	if not cutscene_handler.actor_control_active:
		
		if qte_handler.actor_control_active:
			qte_input()
		return
	elif state==States.STAGGERED:
		return
	#print(hit_stop.dur.time_left)
	var input_axis = Input.get_axis("walk_left", "walk_right")
	vel_x=velocity.x
	current_state_label()
	get_target_info()
	previous_state()
	atk_state_debug()
	label.text=str(anim_count)
	#if target != null:
		#label.text=str(target_size_x, " , ",target_size_y)
	#if atk_chain >= 1 and sp_atk_chn >=1:
		#label.text=str("chain ready. Vel:", velocity)
	#else:
		#label.text=str("chain not ready. Vel:", velocity)
	dodge(input_axis, delta)
	if Input.is_action_just_pressed("walk_right"):
		face_right = true
		move_axis = 1
		parry_box.scale.x=1
	elif Input.is_action_just_pressed("walk_left"):
		face_right = false
		move_axis = -1
		parry_box.scale.x=-1
	elif input_axis == 0:
		move_axis = 0
	
	#handle_hitbox(input_axis, face_right)
	#air_atk)
	
	if(state!=States.DODGE and s_atk==false and state!=States.FLIP):
		parry()
		attack_animate()
		update_animation(input_axis)
	elif state == States.FLIP:
		break_out()
	elif state==States.DODGE:
		if Input.is_action_just_pressed("attack"):
			dash_attack()
	
	lockon()
	#air_atk)

func _physics_process(delta):
	#position=path_follow_2d.position
	if not cutscene_handler.actor_control_active or not qte_handler.actor_control_active:
		apply_gravity(delta)
		cutscene_acceleration(cutscene_handler.cutscene_dir, delta)
		move_and_slide()
		#if path_start:
			##position=path_follow_2d.position
			#run_path()
		#camera_2d.global_position=camera_pos.global_position
		return
		
	if s_atk==true:
		return
	elif state==States.FLIP:
		#pass
		
		#apply_gravity(delta)
		flipping(delta)
		sp_atk()
		move_and_slide()
		
		if is_on_floor():
			if state==States.JUMP or (state==States.FLIP and flipped_over):
				set_state(state, States.IDLE)
			
		#velocity = movement * SPEED * delta
	elif state==States.STAGGERED:
		move_and_slide()
		apply_gravity(delta)
		velocity.x=0
	else:
		if combat_state==CombatStates.LOCKED:
			locked_combat()	

		if dodge_state == true:
			state = States.DODGE
		# Add the gravity.
		if(dodge_state==false and parry_stance==false):
			apply_gravity(delta) 
		var input_axis = Input.get_axis("walk_left", "walk_right")
		

		
		#dodge_timer.time_left)
		#parry_stance)
		var wall_hold = false
		if(state!=States.DODGE and parry_stance==false and state!=States.FLIP):
			#"not flip")
			handle_wall_jump(wall_hold, delta)
			jump(input_axis, delta)
			handle_acceleration(input_axis, delta)
			handle_air_acceleration(input_axis, delta)
			apply_friction(input_axis, delta)
			apply_air_resistance(input_axis, delta)
			sp_atk()
			#label.text=str(cur_state, " ", previous)
			#jump_out()
			
		
		#elif state==States.SPECIAL_ATTACK and combo_state!=ComboStates.SPC_ATK_BACK:
			#velocity=Vector2.ZERO
			#gravity=0
			#"no fall")
		#input_axis)
		
		
		var was_on_floor = is_on_floor()
		velocity=velocity + knockback
		move_and_slide()
		var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
		if just_left_ledge:
			coyote_jump_timer.start()
		#if Input.is_action_pressed("sprint"):
			#state=States.SPRINTING
			#movement_data = load("res://FasterMovementData.tres")
		#if Input.is_action_pressed("walk"):
			#movement_data = load("res://SlowMovementData.tres")
		#if Input.is_action_just_released("sprint") or Input.is_action_just_released("walk"):
			#movement_data = load("res://DefaultMovementData.tres")
		just_wall_jump = false
		

		#cur_state)
		var side
		if target_right:
			side = "Right"
		else:
			side = "Left"
		#label.text=str("Vel: ",velocity)
		
		
		knockback = lerp(knockback, Vector2.ZERO, 0.1)
		forward_thrust = lerp(forward_thrust, Vector2.ZERO, 0.6)
		#wall hold check
		if not is_on_wall() or not Input.is_action_pressed("sprint"):
			wall_hold=false
			#"wall hold false")
			gravity = 980
		else:
			#"wall hold true")
			state = States.WALL_STICK
			velocity.x =0
			velocity.y = 0
			gravity = 0
	
	#return_to_idle()

#Toggle player control
#func set_actor_control(value : bool)->void:
	#actor_control_active=value


# Add the gravity.
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta
	
#condtions to return to idle
func return_to_idle():
	if is_on_floor() and state==States.FLIP and flipped_over:
		#"flip end")
		set_state(state, States.IDLE)
		set_collision_mask_value(16384, true)
	
# Handle jump.
func jump(input_axis, delta):

	if is_on_floor(): double_jump_flag = true
	
	if is_on_floor() or coyote_jump_timer.time_left>0.0:
		if Input.is_action_just_pressed("jump"):
			#state = States.JUMP
			set_state(state, States.JUMP)
			velocity.y = movement_data.jump_velocity
			
	elif not is_on_floor() and parry_stance==false and state != States.FLIP:
		#state = States.JUMP
		if Input.is_action_just_released("jump") and velocity.y<movement_data.jump_velocity/2:
			
			velocity.y = movement_data.jump_velocity/2
			#state = States.JUMP
			set_state(state, States.JUMP)
		if Input.is_action_just_pressed("jump") and double_jump_flag == true and just_wall_jump == false:
			
			velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.acceleration*10 * delta)
			velocity.y = movement_data.jump_velocity *0.8
			double_jump_flag = false
			#state = States.JUMP
			set_state(state, States.JUMP)

#breaking out of a flip. Test without timer later
func break_out():
	
	if Input.is_action_just_pressed("jump") and not Input.is_action_pressed("sprint"):
		
		#state=States.IDLE
		set_state(state, States.JUMP)
		jump_out_signal.emit(250)
	elif Input.is_action_just_pressed("attack"):
		attack_combo="Flip_Attack"
		set_state(state, States.ATTACK)
		jump_out(200)
		
		
#jump out of flip
func jump_out(jumpout_vel : float):
	knockback.x=jumpout_vel
	if vector_away.x<0:
		print("jump left")
		knockback.x = knockback.x*-1
	else:
		knockback.x=knockback.x
	velocity.y=movement_data.jump_velocity
	#velocity.x = knockback.x
	hit_stop.hit_stop(1,0)
	set_collision_mask_value(15, true)


func handle_wall_jump(wall_hold, delta):
	if not is_on_wall_only(): return
	if not Input.is_action_pressed("sprint"): return
	var wall_normal = get_wall_normal()

	
	if Input.is_action_just_pressed("walk_left") and wall_normal == Vector2.LEFT and wall_hold == true:
		#state = States.WALL_STICK
		set_state(state, States.WALL_STICK)
		velocity.x =0
		velocity.y = 0
		gravity = 0
		
	elif Input.is_action_just_pressed("walk_right") or Input.is_action_just_pressed("jump") or Input.is_action_just_released("sprint"):
		set_state(state, States.JUMP)
		velocity.x = move_toward(velocity.x, movement_data.speed * wall_normal.x * 1.5, movement_data.acceleration*10 * delta)
		velocity.y = movement_data.jump_velocity
		just_wall_jump = true
		
		
		
		
	if Input.is_action_just_pressed("walk_right") and wall_normal == Vector2.RIGHT and wall_hold == true:
		set_state(state, States.WALL_STICK)
		velocity.x =0
		velocity.y = 0
		gravity = 0
	
	elif Input.is_action_just_pressed("walk_left") or Input.is_action_just_pressed("jump")  or Input.is_action_just_released("sprint"):
		set_state(state, States.JUMP)
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
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0 , movement_data.air_resistance * delta)
# Get the input direction and handle the movement/deceleration.
func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)
		
# Apply friction after dtopping.
func handle_acceleration(input_axis, delta):
	if not is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.acceleration * delta)

# Movement for cutscenes		
func cutscene_acceleration(dir, delta):
	if dir!=0:
		velocity.x = move_toward(velocity.x, (movement_data.speed/3) * dir, movement_data.acceleration * delta)
	else:
		velocity.x=0
		
		
#func set_cutscene_dir(value : int) -> void:
	#cutscene_dir=value
func set_movement_data(value : int) -> void:
	match value:
		0:
			movement_data = load("res://DefaultMovementData.tres")
		1:
			movement_data = load("res://SlowMovementData.tres")
		2:
			movement_data = load("res://FasterMovementData.tres")


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
	#var left = Input.is_action_pressed("walk_left")
	#var right = Input.is_action_pressed("walk_right")
	
	
	if combat_state!=CombatStates.LOCKED:
		if input_axis != 0:
		
		#animated_sprite_2d.flip_h = (input_axis<0)
			if input_axis<0:
				if animated_sprite_2d.scale.x>0:
					animated_sprite_2d.scale.x *= -1
			else:
				if animated_sprite_2d.scale.x<0:
					animated_sprite_2d.scale.x *= -1
					
			if state != States.ATTACK and s_atk==false:
				#state = States.WALKING
				
				if Input.is_action_pressed("sprint"):
					if combat_state!=CombatStates.LOCKED:
						walk_anim="run"
						set_state(state, States.SPRINTING)
					else:
						set_state(state, States.WALKING)
					movement_data = load("res://FasterMovementData.tres")
				elif Input.is_action_just_released("sprint"):
					movement_data = load("res://DefaultMovementData.tres")
					walk_anim="walk"
					set_state(state, States.WALKING)
				else:
					set_state(state, States.WALKING)
					walk_anim="walk"
			#idle_state=false
	else:
		if not target_right:
			if animated_sprite_2d.scale.x>0:
				animated_sprite_2d.scale.x *= -1
			if input_axis>0:
				walk_anim="walk_back"
			else:
				walk_anim="walk"
		else:
			if animated_sprite_2d.scale.x<0:
				animated_sprite_2d.scale.x *= -1
			if input_axis>0:
				walk_anim="walk"
			else:
				walk_anim="walk_back"
		if (state != States.ATTACK and s_atk==false) and input_axis!=0:
			#state = States.WALKING
			set_state(state, States.WALKING)
		if Input.is_action_pressed("sprint"):
			movement_data = load("res://FasterMovementData.tres")
		elif Input.is_action_just_released("sprint"):
			movement_data = load("res://DefaultMovementData.tres")
	if (Input.is_action_just_released("walk_left") or Input.is_action_just_released("walk_right")) and input_axis==0:
		#state = States.IDLE
		set_state(state, States.IDLE)
		
	if is_on_floor():
		jumping=false
		if state == States.JUMP:
			falling=false
			set_state(state, States.IDLE)
		#animated_sprite_2d.play("jump")
	
		
		
func attack_animate():

	
		
	if Input.is_action_just_pressed("attack") and state != States.ATTACK:
		attack_timer.start()
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
					#animated_sprite_2d.play("attack_1")
					attack_combo = "Attack"
					hit_sound = hit1
					AudioStreamManager.play(swing1)

				elif atk_chain == 1 and sp_atk_chn<1:
					#animated_sprite_2d.play("attack_2")
					attack_combo = "Attack_2"
					hit_sound = hit2
					AudioStreamManager.play(swing2)
				
				elif atk_chain == 2:
					#animated_sprite_2d.play("attack_3")
					attack_combo = "Attack_3"
					hit_sound = hit3
					AudioStreamManager.play(swing3)
				elif sp_atk_chn>=1:
					attack_combo = "Attack_Chain"
					hit_sound = hit2
					AudioStreamManager.play(swing2)
		
		
		#state=States.ATTACK
		set_state(state, States.ATTACK)
		
		await anim_player.animation_finished
		attack_timer.paused=false
		
		
func dash_attack():
	attack_combo = "Attack_Dash"
	hit_sound = hit1
	AudioStreamManager.play(swing1)
	set_state(state, States.ATTACK)

func sp_atk():
	if state==States.FLIP:
		shotty.look_at(target.global_position)
	else:
		shotty.look_at(get_global_mouse_position())
	#sp_atk_hit_box.look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("special_attack") and state != States.SPECIAL_ATTACK:
		
		if attack_timer.is_stopped():
			attack_timer.start()
			attack_timer.paused=true
			
			
		if combo_state==ComboStates.SPC_ATK_BACK:
			
			sp_atk_combo="shotgun_attack_fast"
		else:
			if atk_chain==0:
				if sp_atk_chn == 0 and (not attack_timer.is_stopped()):
					sp_atk_combo="shotgun_attack"
					#"sp_atk 1")
					if state!=States.HIT:
						AudioStreamManager.play(shotgun_fire)
					sp_atk_dmg=1

				elif sp_atk_chn == 1 and (not attack_timer.is_stopped()):
					#animated_sprite_2d.play("attack_2")
					sp_atk_combo="shotgun_attack"
					#"sp_atk 2")
					if state!=States.HIT:
						AudioStreamManager.play(shotgun_fire)
					sp_atk_dmg=1

				elif sp_atk_chn == 2 and (not attack_timer.is_stopped()):
					#animated_sprite_2d.play("attack_3")
					#"reload anim playing")
					if state!=States.HIT:
						AudioStreamManager.play(reload)
					sp_atk_combo="shotgun_attack"
					#"sp_atk 3")
					sp_atk_dmg=2
					
			else:
				sp_atk_combo="shotgun_attack_fast"
				#AudioStreamManager.play(shotgun_fire)
			
		#state=States.SPECIAL_ATTACK
		set_state(state, States.SPECIAL_ATTACK)
		attack_timer.paused = false
		#s_atk=true
		#cpu_particles_2d.emitting=true
		
		#await anim_player.animation_finished
		#attack_timer.paused=false
		#s_atk=false


func parry():
	#parry_box.look_at(get_global_mouse_position())
	#Enter/Exit parry state
	
	
	if Input.is_action_just_pressed("parry"):
		parry_timer.start()
		parry_stance=true
		#state=States.PARRY
		set_state(state, States.PARRY)
		pb_rot.disabled=false
		#if face_right==true:
			#parry_box.scale.x=1
		#if face_right==false:
			#parry_box.scale.x=-1

	elif Input.is_action_just_released("parry"):
		parry_timer.stop()
		parry_stance=false
		#state=States.IDLE
		set_state(state, States.IDLE)
		anim_player.stop()
		#idle_state = true
		
	
	#parry interactions
	if parry_stance==true:
		#animated_sprite_2d.play("parry_stance")
		velocity.x=0
		velocity.y=0

		
			
# DODGE NEEDS WORK!!!
func dodge(input_axis, delta):

	if Input.is_action_just_pressed("Dodge"):
		dodge_timer.start()
		if not is_on_floor():
			velocity.y=0
		
		if input_axis == 0:
			dodge_anim_run=dodge_anim
			velocity.x=0
			#state = States.DODGE
			set_state(state, States.DODGE)
		else:
			#position.x = lerpf(position.x, position.x + (input_axis*2), delta)
			dodge_anim_run=dodge_anim+"_roll"
			#state = States.DODGE
			set_state(state, States.DODGE)
			velocity.x=movement_data.dodge_speed*input_axis
		#if input_axis == 0:
			#position.x = lerpf(position.x, position.x, delta)
			#state = States.DODGE
		#else:
			#if face_right==true:
				#position.x = lerpf(position.x, position.x-1, delta)
				#state = States.DODGE
				#
				#
			#elif face_right==false:
				#position.x = lerpf(position.x, position.x+1, delta)
				#state = States.DODGE
				#
		
	
	
	if (dodge_timer.is_stopped()) and state == States.DODGE:
		#parry_stance=false
		dodge_state=false
		dodge_timer.stop()
		#state=States.IDLE
		set_state(state, States.IDLE)
	
	
#func handle_hitbox(input_axis, face_right):
	#if state== States.ATTACK:
		#if combat_state!=CombatStates.LOCKED:
			#if not face_right:
				#hit_box.scale.x=1
			#else:
				#hit_box.scale.x=-1
		#else:
			#if not target_right:
				#hit_box.scale.x=1
			#else:
				#hit_box.scale.x=-1

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
		combat_state=CombatStates.UNLOCKED
	else:
		
		target_dist=abs(global_position-target.global_position)
		if (target.state_machine.get_active_state()==target.death):
			combat_state=CombatStates.UNLOCKED
			return
		
		combat_state=CombatStates.LOCKED
		var direction_to_target : Vector2 = Vector2(target.position.x, target.position.y) - global_position
		
		var arc_vector = Vector2(position-Vector2(target.position)).normalized()
		target_direction = position.direction_to(target.position)
		
		#raycast from pointing away NEEDS WORK
		var dir_away_from_target : Vector2 = (Vector2(target.position.x, target.position.y) - target_testing.position)
		
		target_locking.look_at(dir_away_from_target)
		vector_away=-((target_testing.to_global(target_testing.target_position) - target_testing.to_global(Vector2.ZERO)).normalized())
		
		if state!=States.FLIP and state!=States.SPECIAL_ATTACK:
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

func _on_hazard_detector_area_entered(area):
	if area.is_in_group("hazard"):
		global_position=starting_position
		
		health.health -= 1
		
	elif area.is_in_group("Enemy"):
		hit_stop.hit_stop(0.05, 0.1)
		knockback.x = input_dir.x * knockback.x *0.25
	
	
	
#State machine for animations currently
func set_state(current_state, new_state: int) -> void:
	#current_state, new_state)

	if(current_state == new_state):
		#"no change")
		return
	#else:
		#current_state, new_state)
		##"changing")
	
	if current_state==States.JUMP:
		air_atk=true
		#if not is_on_floor():
			#return
		#air_atk)
	if current_state == States.PARRY and parry_stance==true:
		pass
	
	prev_state=current_state
	state=new_state
	match new_state:
		States.ATTACK:
			#cur_state="ATTACK"
			anim_player.speed_scale=1.5
			anim_player.play(attack_combo)
			if air_atk==true:
			
				velocity=Vector2.ZERO
				gravity=0
				
		States.SPECIAL_ATTACK:
			anim_player.speed_scale=1.5
			#sp_atk_chn+=1
			if sp_atk_chn==2:
				anim_player.play("shotgun_finish")
				await anim_player.animation_finished
				sp_atk_chn=0
			anim_player.play(sp_atk_combo)
			if current_state==States.FLIP:
				hitstop_time_left=hit_stop.get_time_left()
				print(hitstop_time_left)
				hit_stop.hit_stop(.1,.1)
					
			#if not is_on_floor():
				#velocity=Vector2.ZERO
				#gravity=0
		States.IDLE:
			anim_player.speed_scale=1
			anim_player.play("idle")
			#"playing idle")
			movement_data.friction=1000
			s_atk=false
			counter_box_collision.disabled=true
			hb_collision.disabled=true
			air_atk=false
			flipped_over=false
		States.WALKING:
			anim_player.speed_scale=1
			#if jumping:
				#pass
			#else:
				#anim_player.play("walk")
			anim_player.play("walk")
		States.JUMP:
			jumping=true
			#if falling==false:
				#anim_player.play("jump")
			#else:
				#pass
			cur_state="JUMP"
			anim_player.play("jump")
		States.DODGE:
			hurt_box_detect.disabled=true
			counter_box_collision.disabled=false
			anim_player.speed_scale=1
			anim_player.play(dodge_anim_run)
			set_collision_mask_value(15, false)
			velocity.y=0
			#velocity.x=100 * move_axis
		States.PARRY:
			hurt_box_detect.disabled=true			
			anim_player.play("Parry")
		States.FLIP:
			anim_player.play("flip")
			cur_state="Flipping"
			set_collision_mask_value(15, false)
			high_target_jump_height = (global_position.y-collision_shape_2d.get_shape().size.y)
			if current_state==States.SPECIAL_ATTACK:
				hit_stop.hit_stop(.5, (hitstop_time_left-0.1))
		States.SPRINTING:
			anim_player.speed_scale=1
			#if jumping:
				#pass
			#else:
				#anim_player.play("run")
			anim_player.play("run")
		States.HIT:
			anim_player.play("hit")
			hurt_box_detect.disabled=true
		States.STAGGERED:
			anim_player.play("staggered")
			knockback=Vector2.ZERO
	if state != States.DODGE:
		hurt_box_detect.disabled=false
			
	
				
			
	if state!=States.PARRY:
		pb_rot.disabled=true

func get_state() -> String:
	return cur_state
func get_state_enum() -> int:
	return state

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

func _on_hurt_box_got_hit(hitbox):
	if hitbox.is_in_group("regular_enemy_hb"):
		if hit_timer.is_stopped():
			AudioStreamManager.play(SoundFx.PUNCH_DESIGNED_HEAVY_12)
		player_hit.emitting=true
		player_hit.restart()
		hurt_box_detect.disabled=true
		hit_timer.start(0.2)
		if state!=States.FLIP:
			
			set_state(state, States.HIT)
	elif hitbox.is_in_group("heavy_hitbox"):
		knockback.x = -400
		kb_dir=global_position.direction_to(hitbox.global_position)
		#"knockback")
		kb_dir=round(kb_dir)
		#kb_dir.x, " ", knockback)
		knockback.x = kb_dir.x * knockback.x
		velocity.y=movement_data.jump_velocity/2
		#velocity.x = movement_data.speed + knockback.x
		health.set_temporary_immortality(0.2)
	else:
		set_collision_mask_value(16384, false)
		knockback.x = -350
		kb_dir=global_position.direction_to(hitbox.global_position)
		#"knockback")
		kb_dir=round(kb_dir)
		#kb_dir.x, " ", knockback)
		knockback.x = kb_dir.x * knockback.x
		velocity.y=movement_data.jump_velocity/2
		#velocity.x = movement_data.speed + knockback.x
		health.set_temporary_immortality(0.2)

func _on_hit_timer_timeout() -> void:
	hurt_box_detect.disabled=false
	if state!=States.FLIP:
		set_state(state, States.IDLE)
	player_hit.emitting=false


func _on_hurt_box_area_entered(area):
	if area.is_in_group("bullet"):
		hit_stop.hit_stop(0.05, 0.05)
		knockback.x = -50
		kb_dir=global_position.direction_to(area.global_position)
		#"knockback")
		kb_dir=round(kb_dir)
		#kb_dir.x, " ", knockback)
		knockback.x = kb_dir.x * knockback.x
		velocity.y=movement_data.jump_velocity/2
		#velocity.x = movement_data.speed + knockback.x
		health.health -= 1
		health.set_temporary_immortality(0.2)
		if state==States.FLIP:
			set_state(state, States.IDLE)
		
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
	if state==States.ATTACK:
		#"attack finished")
		hit_success=false
		if anim_name=="Attack_Counter":
			counter_flag=false
			return
		elif anim_name=="Attack_Chain":
			set_state(state, States.IDLE)
			sp_atk_chn=0
			atk_chain=0
			attack_timer.start(1)
			combo_state=ComboStates.SPC_ATK_BACK
			return
		if atk_chain < 2:
			atk_chain += 1
		elif atk_chain >=2:
			atk_chain = 0
			attack_combo = "Attack"
		if prev_state==States.FLIP:
			set_state(state, States.JUMP)
			
		else:
			set_state(state, prev_state)
		hb_collision.disabled=true
		
	elif state==States.SPECIAL_ATTACK:
		if prev_state==States.FLIP:
			if anim_name=="shotgun_attack":
				#flip.emit()
				
				set_state(state, States.FLIP)
				s_atk=false
		else:
			if anim_name=="shotgun_attack":
				if sp_atk_chn < 2:
				
					sp_atk_chn += 1
				#"Attack Chain")
				elif sp_atk_chn >=2:
					sp_atk_chn = 0
				#"special finished")
				s_atk=false
				#state=States.IDLE
				if falling:
					velocity.y=vel_y
				set_state(state, States.IDLE)
			elif anim_name=="shotgun_finish":
				AudioStreamManager.play(shotgun_fire)
				#state=States.IDLE
				s_atk=false
				set_state(state, States.IDLE)
			elif anim_name=="shotgun_attack_fast":
				#AudioStreamManager.play(shotgun_fire)
				sp_atk_chn += 1
				#state=States.IDLE
				s_atk=false
				set_state(state, States.IDLE)
	elif state==States.JUMP:
		if anim_name=="jump":
			falling=true
	elif anim_name=="staggered":
		set_state(state, States.IDLE)
		stagger.stagger=stagger.get_max_stagger()
	
	elif anim_name=="dodge_roll":
		
		velocity.x=0
		counter_box_collision.disabled=true
		set_collision_mask_value(15, true)
	elif anim_name=="dodge":
		
		counter_box_collision.disabled=true
	elif anim_name=="flip":
		
		anim_player.speed_scale=1
		set_state(state, prev_state)
	
	
	
	else:
		pass

func _on_attack_timer_timeout():
	atk_chain = 0
	attack_combo = "Attack"
	sp_atk_chn = 0
	combo_state=ComboStates.ATK_1

func load_player_data():
	var file = FileAccess.open("user://player_data/stats/player_stats.txt", FileAccess.READ)
	if file.file_exists("user://player_data/stats/player_stats.txt"):
		while file.is_open():
			var content = file.get_line()
			var stat : String = content.get_slice(":", 0)
			var stat_val : int = int(content.get_slice(":", 1))
			
			if stat != null:
				match stat:
					"health":
						health.set_health(100)
					"max_health":
						health.set_max_health(100)
					"max_stagger":
						pass
					"ammo":
						ammo=stat_val
						
			if file.eof_reached():
				break
		file.close()
	else:
		print("file not found")

func save_player_data():
	var file = FileAccess.open("user://player_data/stats/player_stats.txt", FileAccess.READ_WRITE)
	if file.file_exists("user://player_data/stats/player_stats.txt"):
		var stat : String = str("health: ", health.get_health())
		file.store_string(stat)
		file.store_string("\n")
		stat = str("max_health: ", health.get_max_health())
		file.store_string(stat)
		file.store_string("\n")
		file.close()
	else:
		print("file not found")


func _on_parry_timer_timeout():
	parry_timer.stop()
	parry_stance=false
	#state=States.IDLE
	set_state(state, States.IDLE)
	anim_player.stop()
	
func parry_success():
	parry_timer.stop()
	anim_player.play("Parry_Success")
	
	AudioStreamManager.play(parry_sfx)
	await anim_player.animation_finished
	anim_player.stop()



func _on_hit_box_area_entered(area):
	hit_sound=hit1
	AudioStreamManager.play(hit_sound)
	#hit_stop.hit_stop(0.05, 0.1)


func _on_hit_box_body_entered(body):
	if body.is_in_group("Enemy") and combat_state==CombatStates.UNLOCKED:
		Events.unlock_from.emit()
		#str(body.name))
		target_string_test=str(body.name)
		target = body
		combat_state=CombatStates.LOCKED
	
	
func flip_over():
	
	flip_speed=movement_data.speed * 80
	
	set_state(state, States.FLIP)
	#state=States.FLIP

func flipping(delta):
#	variables set and declared
	target_pos_y=(target.global_position.y)
	var pos_above_y=target.global_position.y-global_position.y
	target_pos_x=(target.global_position.x)
	var pos_above_x=target.global_position.x-global_position.x
	print(global_position)
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
	
func current_state_label():
	match state:
		States.ATTACK:
			cur_state="ATTACK"
		States.SPECIAL_ATTACK:
			cur_state="SPECIAL_ATTACK"
		States.IDLE:
			cur_state="IDLE"
		States.WALKING:
			cur_state="WALKING"
		States.JUMP:
			cur_state="JUMP"
		States.DODGE:
			cur_state="DODGE"
		States.WALL_STICK:
			cur_state="WALL STICK"
		States.SPRINTING:
			cur_state = "SPRINTING"
		States.PARRY:
			cur_state = "PARRY"
		States.FLIP:
			cur_state = "FLIP"
	
func previous_state():

	match prev_state:
		States.ATTACK:
			previous="ATTACK"
		States.SPECIAL_ATTACK:
			previous="SPECIAL_ATTACK"
		States.IDLE:
			previous="IDLE"
		States.WALKING:
			previous="WALKING"
		States.JUMP:
			previous="JUMP"
		States.DODGE:
			previous="DODGE"
		States.WALL_STICK:
			previous="WALL STICK"
		States.SPRINTING:
			previous = "SPRINTING"
		States.PARRY:
			previous = "PARRY"
		States.FLIP:
			previous = "FLIP"
			

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
		
	elif area.is_in_group("Enemy"):
		print("enemy dodge")


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
		#sp_atk_chn += 1
		#state=States.IDLE
		#set_state(state, States.IDLE)
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
		s_atk=true
	

func _on_hurt_box_received_damage(damage: int) -> void:
	hit_stop.hit_stop(0.05, 0.1)
	if state==States.FLIP:
		#print("countered! your moves are weak!")
		if target_right:
			knockback.x=400
		else:
			knockback.x=-400
		#velocity.x = movement_data.speed + knockback.x
		set_state(state, States.HIT)

func _on_stagger_staggered() -> void:
	knockback.x=0
	velocity=Vector2.ZERO
	set_state(state, States.STAGGERED)
	
func _on_hit_box_parried() -> void:
	anim_player.play("parried")
	hb_collision.disabled=true
	if target_right:
		knockback.x=-40
	else:
		knockback.x=40
	Events.enemy_parried.emit()
	#velocity.x = movement_data.speed + knockback.x

####################
#Cutscene Functions#
####################


func set_path_speed(speed : int) -> void:
	path_speed=speed
	print(path_speed)
func start_path(speed : int):
	set_path_start(true)
	set_path_speed(speed)
	print(speed)
func set_path_start(value) -> void:
	path_start=value

###############
#QTE Functions#
###############

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
