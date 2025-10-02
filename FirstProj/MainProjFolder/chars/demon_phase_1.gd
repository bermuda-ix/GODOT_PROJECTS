extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -400.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#Basic
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var boss_ui: Control = $CanvasLayer/BossUI

#Animation Player
@onready var animation_player: AnimationPlayer = $AnimationPlayer
	#Anim Player for blending animations
@onready var animation_player_sub: AnimationPlayer = $AnimationPlayer/AnimationPlayerSub

#Target lock
@onready var target_lock_node: TargetLock = $TargetLock
#Visible on screen
@onready var on_screen: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

#Behaviour Tree Player
@onready var bt_player: BTPlayer = $BTPlayer
#Particles
#@onready var gpu_particles_2d: GPUParticles2D = $AnimatedSprite2D/GPUParticles2D

#@onready var left_explosion: GPUParticles2D = $AnimatedSprite2D/LeftExplosion
#@onready var left_sparks: GPUParticles2D = $AnimatedSprite2D/LeftExplosion/GPUParticles2D
#@onready var right_explosion: GPUParticles2D = $AnimatedSprite2D/RightExplosion
#@onready var right_sparks: GPUParticles2D = $AnimatedSprite2D/RightExplosion/GPUParticles2D

#Cutscene Handler
@onready var cutscene_handler: CutsceneHandler = $CutsceneHandler
signal death_cutscene
#On Screen

#Defense
@onready var health: Health = $Health
@onready var stagger: Stagger = $Stagger
@onready var hurt_box: HurtBox = $HurtBox
@onready var hurt_box_collision: CollisionShape2D = $HurtBox/CollisionShape2D

@onready var hit_stop: HitStop = $HitStop
@onready var hit_stop_dur = 0.0

@onready var phases_handler: PhasesHandler = $PhasesHandler

#Timers
@onready var navigation_timer: Timer = $NavigationTimer
@onready var jump_timer: Timer = $JumpTimer
@onready var parry_timer: Timer = $ParryTimer
@onready var chase_timer: Timer = $ChaseTimer
@onready var death_timer: Timer = $DeathTimer
@onready var dodge_timer: Timer = $DodgeTimer
@onready var attack_timer: Timer = $AttackTimer
@onready var stagger_timer: Timer = $StaggerTimer
@onready var tele_delay_timer: Timer = $TeleDelayTimer
@onready var hazard_spawn_timer: Timer = $HazardSpawnTimer


@onready var tele_delay : float = 1.0

#movement
@onready var movement_handler: MovementHandler = $MovementHandler
@onready var jump_handler: JumpHandler = $JumpHandler
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@export var jump_speed : float = 120.0
@export var chase_speed : float = 80.0
@export var keep_dis_speed : float = 40.0
@onready var gravity_active : bool = true : set = set_grav_active
@onready var dash_start : Vector2 = Vector2.ZERO
@onready var dash_stop : Vector2 = Vector2.ZERO
@onready var dash_dist : int = 200 : set = set_dash_dist
@export var dash_finished : bool = true
@onready var rotate_to_player : bool : set=set_rotate_to_player
@onready var tele_dest : String = "above"

var current_speed : float = 40.0
var prev_speed : float = 40.0
var acceleration : float = 800.0
var jump_velocity = JUMP_VELOCITY
var knockback : Vector2 = Vector2.ZERO
var next_y
var next_x
var next
var dir
@export var landed : bool = true

#Player Character Data
@onready var player_right : bool = false
@onready var player_tracking_handler: PlayerTrackingHandler = $PlayerTrackingHandler
@onready var vision_handler: VisionHandler = $VisionHandler
@onready var get_player_info_handler: GetPlayerInfoHandler = $GetPlayerInfoHandler
@onready var player_tracker_pivot: Node2D = $PlayerTrackerPivot
@onready var player_tracking: RayCast2D = $PlayerTrackerPivot/PlayerTracking
@onready var chase_handler: ChaseHandler = $ChaseHandler
@onready var chase_distance : bool = true
var player_found : bool = false
var player : PlayerEntity = null
var distance
var player_state : LimboState
var player_above : Vector2
var player_top_right : Vector2
var player_top_left : Vector2

#States
@onready var state_machine: LimboHSM = $LimboHSM
@onready var idle: LimboState = $LimboHSM/IDLE
@onready var chasing: LimboState = $LimboHSM/CHASING
@onready var jump: LimboState = $LimboHSM/JUMP
@onready var death: LimboState = $LimboHSM/DEATH
@onready var dying: BTState = $LimboHSM/DYING
@onready var attack: LimboState = $LimboHSM/ATTACK
@onready var charge: LimboState = $LimboHSM/CHARGE
@onready var teleport: LimboState = $LimboHSM/TELEPORT
@onready var mid_teleport: LimboState = $LimboHSM/MidTeleport
@onready var dash: LimboState = $LimboHSM/DASH
@onready var slam: Slam = $LimboHSM/Slam
@onready var slam_heavy: Slam = $LimboHSM/SlamHeavy

@onready var phase_transition: BTState = $LimboHSM/PhaseTransition

#TO BE REMOVED
@onready var error_state: LimboState = $LimboHSM/ERROR_STATE


#@onready var dodge: LimboState = $LimboHSM/DODGE
@onready var hit: LimboState = $LimboHSM/HIT
@onready var staggered: LimboState = $LimboHSM/STAGGERED
var state

#State machine for phases
@onready var phases: LimboHSM = $Phases
@onready var phase_1: LimboState = $Phases/Phase1
@onready var phase_2: LimboState = $Phases/Phase2
@onready var phase_3: LimboState = $Phases/Phase3




#ATTACKS
#@onready var melee_attack_manager: MeleeAttackManager = $MeleeAttackManager
@onready var dodge_manager: DodgeManager = $DodgeManager
@onready var attack_range: AttackRange = $AttackRange
@onready var attack_range_long: AttackRange = $AttackRangeLong
@onready var ar_box: CollisionShape2D = $AttackRange/CollisionShape2D
@onready var hit_box: HitBox = $HitBox
@onready var hb_collision: CollisionShape2D = $HitBox/CollisionShape2D
@onready var atk_chain : String = "_1"
@export var hitbox: HitBox
@onready var ground_hazard_spawn_handler: GroundHazardSpawnHandler = $GroundHazardSpawnHandler
@onready var ground_hazard_spawn_handler_left: GroundHazardSpawnHandler = $AnimatedSprite2D/GroundHazardSpawnHandlerLeft
@onready var ground_hazard_spawn_handler_right: GroundHazardSpawnHandler = $AnimatedSprite2D/GroundHazardSpawnHandlerRight

var parried : bool = false 
var attacking : bool = false
var slam_vel : float = 100.0
var attack_chance : int = 50

#Shooting
#@onready var shoot_attack_manager: ShootAttackManager = $ShootAttackManager
#@onready var shoot_handler: ShootHandler = $ShootHandler
#@onready var bullet_dir = Vector2.RIGHT
#@onready var turret: Turret = $Turret
#@onready var ammo_count = 0

#DEATH
@export var drop = preload("res://heart.tscn")
@onready var death_handler: DeathHandler = $DeathHandler
@export var death_time_scale: float = 1.0
@onready var norm_delta

#LVL Boss flag
@export var lvl_boss : bool = false

#Debug var
var combat_state : String = "RANGED"
#@onready var debuging: Label = $DEBUGING

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	_init_state_machine()
	_init_phase_state_machine()
	animation_player.play("idle")
	boss_ui.activate_boss_ui()
	boss_ui.set_max_boss_health(health.max_health)
	boss_ui.set_boss_health(health.health)
	dying.blackboard.set_var("hit_the_floor", false)
	if not state_machine.has_transition(phase_transition, &"hit"):
		print("wubbba lubba dub dub")



func _init_state_machine():
	state_machine.initial_state=idle
	state_machine.initialize(self)
	state_machine.set_active(true)

	state_machine.add_transition(idle, attack, &"attack_mode")
	state_machine.add_transition(staggered, teleport, &"stagger_recover")
	state_machine.add_transition(attack, chasing, &"start_chase")
	state_machine.add_transition(idle, chasing, &"start_chase")
	state_machine.add_transition(chasing, attack, &"start_attack")
	state_machine.add_transition(chasing, dash, &"dash")

	
	state_machine.add_transition(attack, idle, &"idle_mode")
	state_machine.add_transition(attack, jump, &"jump_attack")
	state_machine.add_transition(chasing, jump, &"jump")
	state_machine.add_transition(jump, chasing, &"land")
	state_machine.add_transition(jump, attack, &"land_attack")
	state_machine.add_transition(hit, attack, &"hit_recover")
	#state_machine.add_transition(attack, dodge, &"dodge")
	#state_machine.add_transition(dodge, attack, &"dodge_end")
	
	state_machine.add_transition(chasing, charge, &"charge_attack")
	state_machine.add_transition(chasing, teleport, &"teleport")
	state_machine.add_transition(charge, attack, &"heavy_attack")
	state_machine.add_transition(charge, teleport, &"teleport_counter")
	state_machine.add_transition(teleport, mid_teleport, &"prepare_slam")
	state_machine.add_transition(charge, mid_teleport, &"counter_attack")
	state_machine.add_transition(mid_teleport, slam, &"slam_attack")
	state_machine.add_transition(mid_teleport, slam_heavy, &"slam_attack_heavy")
	state_machine.add_transition(slam, attack, slam.success_event)
	state_machine.add_transition(slam_heavy, attack, slam_heavy.success_event)
	
	state_machine.add_transition(hit, chasing, &"hit_recover")
	
	state_machine.add_transition(attack, teleport, &"teleport_combo")
		
	state_machine.add_transition(state_machine.ANYSTATE, phase_transition, &"phase_transition")
	state_machine.add_transition(phase_transition, chasing, phase_transition.success_event)
	#state_machine.add_transition(phase_transition, error_state, phase_transition.success_event)
	
	state_machine.add_transition(chasing, hit, &"hit")
	state_machine.add_transition(charge, hit, &"hit")
	state_machine.add_transition(attack, hit, &"hit")
	state_machine.add_transition(staggered, hit, &"hit")
	
	state_machine.add_transition(state_machine.ANYSTATE, dying, &"die")
	state_machine.add_transition(dying, death, dying.success_event)
	state_machine.add_transition(state_machine.ANYSTATE, staggered, &"staggered")
	
	
#
func _init_phase_state_machine():
	phases.initial_state=phase_1
	phases.initialize(self)
	phases.set_active(true)
	
	phases.add_transition(phase_1, phase_2, &"phase_2_begin")
	phases.add_transition(phase_2, phase_3, &"phase_3_begin")


func _process(delta: float) -> void:
	if not cutscene_handler.actor_control_active: 
		return
	
	vision_handler.handle_vision()
		
	if state_machine.get_active_state()==idle and not animation_player.is_playing():
		animation_player.play("idle")
		
	start_chase()
	
func _physics_process(delta: float) -> void:
	if not cutscene_handler.actor_control_active:
		apply_gravity(delta)
		current_speed=0
		move_and_slide()
		return
		
	knockback = lerp(knockback, Vector2.ZERO, 0.1)
	
	if  state_machine.get_active_state()==hit or state_machine.get_active_state()==staggered:
		#hb_collison.disabled=true
		velocity.y += gravity * delta
		velocity.x=0
		move_and_slide()
		return
	elif state_machine.get_active_state()==mid_teleport:
		velocity=Vector2.ZERO
		move_and_slide()
		return
	elif state_machine.get_active_state()==dying:
		death_handler.dying()
	elif state_machine.get_active_state()==death :
		hb_collision.disabled=true
		return
	#elif state_machine.get_active_state()==dash:
		#global_position.move_toward(dash_end, delta)
		##print(global_position.move_toward(dash_end, delta), " ", global_position.x, " ", dash_end.x)
		#print(dash_start.move_toward(dash_end, delta*10))
		#move_and_slide()
		
	apply_gravity(delta)
	if state_machine.get_active_state()==chasing:
		velocity.x = current_speed + knockback.x
	else:
		velocity.x= knockback.x
	move_and_slide()
	
func apply_gravity(delta : float) -> void:
	if not gravity_active:
		return
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		dying.blackboard.set_var("hit_the_floor", true)

func set_grav_active(value:bool) -> void:
	gravity_active=value

func makepath() -> void:
	nav_agent.target_position = player.global_position
	
func target_lock():
	Events.unlock_from.emit()
	target_lock_node.target_lock()
	
func chase():
	#set_state(current_state, States.CHASE)
	state_machine.dispatch(&"start_chase")
	
func set_rotate_to_player(value:bool):
	rotate_to_player=value
func look_to_player():
	global_rotation=player_tracker_pivot.global_rotation
	
func get_width() -> int:
	return abs(collision_shape_2d.get_shape().radius * scale.x)
func get_height() -> int:
	return abs(collision_shape_2d.get_shape().height * scale.y)



func start_chase() -> void:
	if chase_distance:
		chase()
		

func left_shockwave_spawn():
	ground_hazard_spawn_handler_left.spawn_hazard()
	
func right_shockwave_spawn():
	ground_hazard_spawn_handler_right.spawn_hazard()

func shake_screen(str: int, fade : int):
	Events.camera_shake.emit(str,fade)

func _on_navigation_timer_timeout() -> void:
	makepath()



func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and state_machine.get_active_state()!=staggered:
		chase_distance=false
		
		#if randi_range(0, 100) > attack_chance:
			#state_machine.dispatch(&"start_attack")
		#else:
			#state_machine.dispatch(&"charge")
			#
	state_machine.dispatch(&"charge_attack")

func _on_attack_range_long_body_entered(body: Node2D) -> void:
	
	#if randi_range(0, 100) > attack_chance:
			#
	if body.is_in_group("player") and state_machine.get_active_state()!=staggered:
		state_machine.dispatch(&"teleport")
		tele_delay=2.0
		#state_machine.dispatch(&"dash")
		
	else:
		pass
			





func _on_attack_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and (state_machine.get_active_state()!=attack and state_machine.get_active_state()!=charge):
		chase_distance=true


func _on_limbo_hsm_active_state_changed(current: LimboState, previous: LimboState) -> void:
	if previous==phase_transition:
		print(current)
		push_error("CHECKING NEXT PHASE")

#Attack State Functions
func _on_attack_entered() -> void:
	if state_machine.get_previous_active_state()==charge:
		animation_player.play("heavy_attack")
	else:
		animation_player.play("attack")
		
		
func _on_attack_exited() -> void:
	hitbox.set_damage(1)


func _on_health_health_depleted() -> void:
	hit_stop.hit_stop(.3, 1)
	state_machine.dispatch(&"die")



func _on_hurt_box_received_damage(damage: int) -> void:
	phases_handler.phase_change(health.health)
	if state_machine.get_active_state()!=staggered and health.health>0 and state_machine.get_active_state()!=phases_handler:
		state_machine.dispatch(&"hit")
	#animation_player_sub.play("hit_noninter")

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("sp_atk_default"):
		#print("spc_hit")
		stagger.stagger -= player.sp_atk_dmg*player.clash_power.clash_power
		if state_machine.get_active_state()!=staggered and health.health>0:
			state_machine.dispatch(&"hit")


func _on_parry_timer_timeout() -> void:
	pass # Replace with function body.


func _on_animation_player_animation_started(anim_name: StringName) -> void:
	if phases.get_active_state()==phase_transition:
		if anim_name=="slam":
			print("BANANA SLAMMA")
		return
		
	if anim_name=="idle":
		if not animation_player.is_playing():
			print("animation broke")
	


func _on_stagger_staggered() -> void:
	state_machine.dispatch(&"staggered")
	stagger_timer.start(3)
	
func stagger_recover() -> void:
	stagger_timer.stop()
	
func _on_stagger_timer_timeout() -> void:
	if health.health>0:
		state_machine.dispatch(&"stagger_recover")

func _on_animation_player_animation_changed(old_name: StringName, new_name: StringName) -> void:
	if phases.get_active_state()==phase_transition:
		return
	if old_name=="idle":
		print("did not exit right")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if phases.get_active_state()==phase_transition:
		return
	match anim_name:
		"teleport":
			teleport_to(tele_delay, "above")
			state_machine.dispatch(&"prepare_slam")
		"mid_teleport":
			if phases.get_active_state()==phase_1:
				state_machine.dispatch(&"slam_attack")
			else:
				state_machine.dispatch(&"slam_heavy_attack")
		"hit":
			state_machine.dispatch(&"hit_recover")
		"dead":
			queue_free()
		"heavy_attack":
			state_machine.dispatch(&"start_chase")
		"attack":
			state_machine.dispatch(&"start_chase")
		"ranged_attack":
			state_machine.dispatch(&"start_chase")
		"dash_start":
			animation_player.play("dashing")
		"dash_end":
			state_machine.change_active_state(chasing)

######################
# Teleport functions #
######################
func teleport_to(delay : float, pos : String = tele_dest) -> void:
	match pos:
		"left":
			global_position=Vector2(player.global_position.x-30, player.global_position.y-15)
		"right":
			global_position=Vector2(player.global_position.x+30, player.global_position.y-15)
		"upleft":
			global_position=Vector2(player.global_position.x-30, player.global_position.y-60)
		"upright":
			global_position=Vector2(player.global_position.x+30, player.global_position.y-60)
		"above":
			global_position=Vector2(player.global_position.x, player.global_position.y-80)
		"defualt":
			global_position=Vector2(player.global_position.x, player.global_position.y-60)
	tele_delay_timer.start(delay)

func set_tele_dest(value : String) -> void:
	tele_dest=value

func _on_teleport_updated(delta: float) -> void:
	pass # Replace with function body.

func _on_teleport_entered() -> void:
	movement_handler.active=false

##################
# Dash functions #
##################

func dash_begin() -> void:
	dash_start=global_position
	movement_handler.active=false
	gravity_active=false
	ground_hazard_spawn_handler.player_trigger=true
	collision_shape_2d.disabled=true
	#hazard_spawn_timer.start(.2)
	dash_finished=false
	if player_right:
		dash_stop=Vector2(global_position.x+dash_dist, global_position.y)
	else:
		dash_stop=Vector2(global_position.x-dash_dist, global_position.y)

func dash_to(delta: float) -> void:
	global_position=dash_torwards(dash_stop, 5, delta)
	collision_shape_2d.disabled=true
	if global_position.x==dash_stop.x:
		dash_finished=true
		animation_player.play("dash_end")

func dash_torwards(end_pos : Vector2, speed : float, delta : float)->Vector2:
	return global_position.move_toward(dash_stop, delta*(SPEED*speed))

func dash_end() -> void:
	gravity_active=true
	movement_handler.active=true
	collision_shape_2d.disabled=false
	hazard_spawn_timer.stop()
	ground_hazard_spawn_handler.player_trigger=false
	dash_finished=true

func set_dash_dist(value:int) -> void:
	dash_dist=value

func _on_dash_entered() -> void:
	dash_begin()

func _on_dash_updated(delta: float) -> void:
	dash_to(delta)

func _on_dash_exited() -> void:
	dash_end()




func _on_hit_box_area_entered(area: Area2D) -> void:
	if player_right:
		player.knockback.x=20
	else:
		player.knockback.x=-20



func _on_charge_timer_timeout() -> void:
	hitbox.set_damage(3)
	state_machine.dispatch(&"heavy_attack")


func _on_charge_updated(delta: float) -> void:
	pass
	#if player.attacking==true:
		#state_machine.dispatch(&"counter_attack")`
		#teleport_to(0.1)


func _on_animation_player_sub_animation_finished(anim_name: StringName) -> void:
	pass
	#animation_player_sub.play("RESET")
	#gravity_active=true
	#match phases_handler.cur_phase:
		#2:
			#phases.dispatch(&"phase_2_begin")
		#3:
			#phases.dispatch(&"phase_3_begin")
			
func _on_animation_player_sub_animation_started(anim_name: StringName) -> void:
	if anim_name=="phase_transitions/phase_1_to_2":
		print("starting phase transition")
	


func _on_death_entered() -> void:
	boss_ui.visible=false
	animation_player.play("dead")


func _on_dying_updated(delta: float) -> void:
	if is_on_floor():
		dying.blackboard.set_var("hit_the_floor", true)


func _on_dying_entered() -> void:
	hit_stop.hit_stop(0.3, 3)
	print("dying")


func _on_charge_entered() -> void:
	movement_handler.face_player_active=false


func _on_charge_exited() -> void:
	movement_handler.face_player_active=true


func _on_hazard_spawn_timer_timeout() -> void:
	ground_hazard_spawn_handler.spawn_hazard()


func _on_phases_handler_next_phase() -> void:
	hit_stop.hit_stop(.5, 1)
	state_machine.dispatch(&"phase_transition")

func set_bt_slam_on_floor_flag(value : bool) -> void:
	slam.blackboard.set_var("landed",value)

func _on_phase_2_entered() -> void:

	hb_collision.disabled=true
	gravity_active=true

func _on_phase_transition_entered() -> void:
	animation_player.stop()
	stagger_recover()
	hb_collision.disabled=true
	print(phase_transition.is_active())
	


func _on_error_state_entered() -> void:
	state_machine.set_active(false)
	print("PHASE_TREE_FAILED")
	push_error("PHASE_TREE_FAILED")


func _on_phase_transition_updated(delta: float) -> void:
	if is_on_floor():
		landed=true
