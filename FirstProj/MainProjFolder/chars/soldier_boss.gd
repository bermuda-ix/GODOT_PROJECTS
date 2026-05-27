class_name SoldierEnemyBoss
extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -400.0
const BALL_PROCETILE = preload("res://Component/ball_procetile.tscn")

signal boss_reloaded

# Get the gravity from the project settings to be synced with RigidBody nodes.
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var wall_check_left = $WallChecks/WallCheckLeft as RayCast2D
@onready var wall_check_right = $WallChecks/WallCheckRight as RayCast2D
@onready var floor_checks_left = $FloorChecks/FloorChecksLeft as RayCast2D
@onready var floor_checks_right = $FloorChecks/FloorChecksRight as RayCast2D
@onready var player_tracking = $PlayerTrackerPivot/PlayerTracking as RayCast2D
@onready var player_tracker_pivot = $PlayerTrackerPivot as Node2D
@onready var vision_handler: VisionHandler = $VisionHandler
var always_active : bool

@onready var chase_timer = $ChaseTimer as Timer
@onready var animated_sprite_2d = $AnimatedSprite2D as AnimatedSprite2D
@onready var animation_player = $AnimationPlayer as AnimationPlayer
@onready var nav_agent = $NavigationAgent2D
@onready var jump_timer = $JumpTimer
@onready var movement_handler: MovementHandler = $MovementHandler

#Cutscene Vars
@onready var speed: Label = $Speed
@onready var cutscene_handler: CutsceneHandler = $CutsceneHandler
@onready var qte_handler: QTEHandler = $QTEHandler
@export var death_cutscene : bool

@export var drop = preload("res://heart.tscn")
@onready var death_timer = $DeathTimer
@export var explode = preload("res://Component/explosion.tscn")

@onready var floor_jump_check_right = $JumpChecks/FloorJumpCheckRight as RayCast2D
@onready var floor_jump_check_left = $JumpChecks/FloorJumpCheckLeft as RayCast2D
@onready var gap_check_left = $JumpChecks/GapCheckLeft as RayCast2D
@onready var gap_check_right = $JumpChecks/GapCheckRight as RayCast2D
@onready var leap_up_check_left = $JumpChecks/LeapUpCheckLeft
@onready var leap_up_check_right = $JumpChecks/LeapUpCheckRight

@onready var teleport_handler: TeleportHandler = $TeleportHandler




@onready var turret = $Turret
@onready var bullet = BALL_PROCETILE
@onready var bullet_dir = Vector2.RIGHT
#@onready var shooting_cooldown = $ShootingCooldown
@onready var shoot_handler: ShootHandler = $ShootHandler
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $Turret/AudioStreamPlayer2D


@onready var health = $Health
@onready var hurt_box = $HurtBox
@onready var hurt_box_collision: CollisionShape2D = $HurtBox/CollisionShape2D
@onready var hb_collision = $HitBox/CollisionShape2D
@onready var hit_box: HitBox = $HitBox

@onready var h_bar = $HBar
@onready var parry_timer = $ParryTimer as Timer
var immortal = false
@onready var stagger = $Stagger
#@onready var hurt_box_weak_point = $AnimatedSprite2D/HurtBox_WeakPoint
@onready var attack_timer: Timer = $AttackTimer
@onready var stagger_timer: Timer = $StaggerTimer
@onready var gpu_particles_2d: GPUParticles2D = $AnimatedSprite2D/GPUParticles2D
@onready var dodge_timer: Timer = $DodgeTimer
@onready var counter_timer: Timer = $CounterTimer

@onready var boss_ui: Control = $CanvasLayer/BossUI


@onready var collision_shape_2d = $CollisionShape2D

@onready var bt_player = $BTPlayer

@onready var jump_handler: JumpHandler = $JumpHandler
@export var jump_speed : float = 120.0
@export var chase_speed : float = 80.0
@export var hitbox: HitBox
@onready var target_lock_node: Node2D = $TargetLock
@onready var attack_range: AttackRange = $AttackRange
@onready var bullet_detection: BulletDetection = $BulletDetection

@onready var on_screen: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@export var counter_kick_chance : int = 0
@onready var counter_flag : bool = false
@onready var locked_on : bool = false
@onready var clash_power: ClashPower = $ClashPower
@onready var clash_mult = clash_power.clash_power
@onready var clash_timer: Timer = $ClashTimer


@onready var current_speed : float = 40.0
@onready var prev_speed : float = 40.0
@onready var acceleration : float = 800.0
@onready var player_found : bool = true
@onready var player : PlayerEntity = null
@onready var jump_velocity = JUMP_VELOCITY
@onready var knockback : Vector2 = Vector2.ZERO
@onready var parried : bool = false 
@onready var attacking : bool = false
@onready var attack_missed : bool = false
@onready var player_behind : bool = false
var next_y
var next_x
var next
var dir
var state
var distance
#player relative locations
@onready var player_right : bool = false

#ATTACKS
@onready var atk_chain : String = "_1"
@onready var melee_attack_manager: MeleeAttackManager = $MeleeAttackManager
@onready var shoot_attack_manager: ShootAttackManager = $ShootAttackManager
@onready var dash_attacking : bool = false

@onready var hit_stop: HitStop = $HitStop
@onready var hit_stop_dur = 0.1

@onready var death_handler: DeathHandler = $DeathHandler

#State Machine
@onready var state_machine : LimboHSM = $LimboHSM
#states
@onready var idle: LimboState = $LimboHSM/IDLE
@onready var chasing: LimboState = $LimboHSM/CHASING
@onready var jump: LimboState = $LimboHSM/JUMP
@onready var death: LimboState = $LimboHSM/DEATH
@onready var dying: BTState = $LimboHSM/DYING
@onready var attack: LimboState = $LimboHSM/ATTACK
@onready var shooting: LimboState = $LimboHSM/SHOOTING
@onready var dodge: LimboState = $LimboHSM/DODGE
@onready var bulletdodge: BulletDodge = $LimboHSM/BULLETDODGE
@onready var hit: LimboState = $LimboHSM/HIT
@onready var staggered: LimboState = $LimboHSM/STAGGERED
@onready var teleport_and_shoot: BTState = $LimboHSM/TeleportAndShoot
@onready var teleport_and_hit: BTState = $LimboHSM/TeleportAndHit
@onready var launch: Launch = $LimboHSM/Launch
@onready var clashed: Clashed = $LimboHSM/Clashed
@onready var falling: Falling = $LimboHSM/Falling
@onready var land: Land = $LimboHSM/Land


@onready var teleport_helper_raycast: RayCast2D = $RayCast2D





#Counter States
@onready var counter_sm: LimboHSM = $LimboHSM/COUNTER
@onready var begin_counter: LimboState = $LimboHSM/COUNTER/BeginCounter
@onready var kick_counter: LimboState = $LimboHSM/COUNTER/KickCounter


@onready var combat_state_machine: LimboHSM = $CombatStateMachine
@onready var ranged_mode: LimboState = $CombatStateMachine/RANGED
@onready var melee_mode: LimboState = $CombatStateMachine/MELEE

@onready var phase_transition: BTState = $LimboHSM/PHASETRANSITION
@onready var phases: LimboHSM = $Phases
@onready var phase_1: LimboState = $Phases/Phase1
@onready var phase_2: LimboState = $Phases/Phase2
@onready var phases_handler: PhasesHandler = $PhasesHandler
@onready var changing_phase := false
@onready var combat_state_change_handler: CombatStateChangeHandler = $CombatStateChangeHandler

var spawn_loc : Vector2

@onready var ammo_count

#DEBUG
func _set(global_position, value):
	global_position=value

#Defaults for reset
const vision_active = false
const vision_stay_on = true
const vision_always_on = false

enum CombatStates{
	RANGED,
	MELEE,
	}
	
var current_combat_state = CombatStates.RANGED
var prev_combat_state = CombatStates.RANGED
var combat_state : String = "RANGED"
var player_state : LimboState

var is_on_screen : bool
	
	
	
	
@export_category("Boss Variables")
@export var lvl_boss : bool
@export var death_flag_name : String
	
func _ready():
	#vision_active=vision_handler.active
	#vision_stay_on=vision_handler.stay_on
	#vision_always_on=vision_handler.always_on

	player = get_tree().get_first_node_in_group("player")
	#set_state(current_state, States.CHASE)
	ammo_count=turret.ammo_count
	bullet = BALL_PROCETILE
	animation_player.play("idle")
	state="guard"
	melee_attack_manager.combo_max=3
	next=nav_agent.get_next_path_position()
	bt_player.blackboard.set_var("attack_mode", false)
	bt_player.blackboard.set_var("melee_mode", false)
	bt_player.blackboard.set_var("ranged_mode", true)
	bt_player.blackboard.set_var("within_range", false)
	bt_player.blackboard.set_var("counter_attack", false)
	bt_player.blackboard.set_var("counter_kick_flag", false)
	bt_player.blackboard.set_var("staggered", false)
	bt_player.blackboard.set_var("Phase2Active", false)
	bt_player.blackboard.set_var("launched", false)
	bt_player.blackboard.set_var("falling", false)
	bt_player.blackboard.set_var("hit", false)
	bt_player.blackboard.set_var("dodge", false)
	bt_player.blackboard.set_var("atk_1", true)
	bt_player.blackboard.set_var("atk_2", false)
	bt_player.blackboard.set_var("dash_hit", false)
	
	
	dying.blackboard.set_var("hit_the_floor", false)
	
	print_debug(bt_player.blackboard.list_vars())
	
	#turret.setup(0.2)
	boss_ui.activate_boss_ui()
	boss_ui.set_max_boss_health(health.max_health)
	boss_ui.set_boss_health(health.health)
	boss_ui.set_deferred("visible", true)
	turret.shoot_timer.paused=true
	_init_state_machine()
	_init_combat_state_machine()
	_init_counter_state_machine()
	_init_phase_state_machine()
	hurt_box.set_damage_mulitplyer(1)
	Events.allied_enemy_hit.connect(adjust_counter)
	Events.game_over.connect(game_over)
	#Events.reload_level_checkpoint.connect(boss_reset)
	vision_handler.active=vision_active
	vision_handler.stay_on=vision_stay_on
	vision_handler.always_on=vision_always_on
	state_machine.change_active_state(idle)
	bt_player.active=false
	
	player_tracking.target_position=Vector2(vision_handler.vision_range,0)
	if health.health<=0:
		queue_free()
	if always_active:
		alerted()
		
	
	print_debug(global_position)
# initialize state
func _init_state_machine():
	state_machine.initial_state=idle
	state_machine.initialize(self)
	state_machine.set_active(true)

	state_machine.add_transition(idle, attack, &"attack_mode")
	state_machine.add_transition(staggered, chasing, &"stagger_recover")
	state_machine.add_transition(attack, chasing, &"start_chase")
	state_machine.add_transition(shooting, chasing, &"start_chase")
	state_machine.add_transition(chasing, attack, &"start_attack")
	state_machine.add_transition(attack, idle, &"idle_mode")
	state_machine.add_transition(attack, jump, &"jump_attack")
	state_machine.add_transition(chasing, jump, &"jump")
	state_machine.add_transition(jump, chasing, &"land")
	state_machine.add_transition(jump, attack, &"land_attack")
	state_machine.add_transition(hit, attack, &"hit_recover")
	state_machine.add_transition(attack, dodge, &"dodge")
	state_machine.add_transition(dodge, attack, &"dodge_end")
	state_machine.add_transition(attack, counter_sm, &"counter")
	state_machine.add_transition(counter_sm, attack, &"counter_end")
	state_machine.add_transition(shooting, bulletdodge, &"bullet_dodge")
	state_machine.add_transition(chasing, bulletdodge, &"bullet_dodge")
	state_machine.add_transition(attack, bulletdodge, &"bullet_dodge")
	state_machine.add_transition(bulletdodge, chasing, &"finish_bullet_dodge")
	state_machine.add_transition(bulletdodge, attack, &"resume_attack")
		
	state_machine.add_transition(staggered, launch, &"launched")
	state_machine.add_transition(launch, falling, &"falling")
	state_machine.add_transition(falling, land, &"landed")
	state_machine.add_transition(land, attack, &"start_attack")
		
	state_machine.add_transition(state_machine.ANYSTATE, hit, &"hit")
	state_machine.add_transition(state_machine.ANYSTATE, dying, &"die")
	state_machine.add_transition(dying, death, dying.success_event)
	state_machine.add_transition(state_machine.ANYSTATE, staggered, &"staggered")
	
	state_machine.add_transition(attack, clashed, &"clashed")
	state_machine.add_transition(clashed, attack, &"resume_attack")
	
	state_machine.add_transition(state_machine.ANYSTATE, phase_transition, &"begin_next_phase")
	state_machine.add_transition(phase_transition, teleport_and_shoot, phase_transition.success_event)
	state_machine.remove_transition(dying, &"begin_next_phase")
	state_machine.remove_transition(death, &"begin_next_phase")
	
	
func _init_TEST_state_machine():
	state_machine.initial_state=idle
	state_machine.initialize(self)
	state_machine.set_active(true)
	
	state_machine.add_transition(idle, teleport_and_shoot, &"teleport_counter")
	
	state_machine.add_transition(teleport_and_shoot, idle, teleport_and_shoot.success_event)
	state_machine.add_transition(idle, hit, &"got_hit")
	state_machine.add_transition(hit, idle, &"hit_recover")

func test_function():
	state_machine.dispatch(&"teleport_counter")


func _init_phase_state_machine():
	phases.initial_state=phase_1
	phases.initialize(self)
	phases.set_active(true)
	
	phases.add_transition(phase_1, phase_2, &"next_phase")

func _init_counter_state_machine():
	counter_sm.initial_state=begin_counter
	counter_sm.initialize(self)
	counter_sm.add_transition(begin_counter, kick_counter, &"kick_counter")


func _init_combat_state_machine():
	combat_state_machine.initial_state=ranged_mode
	combat_state_machine.initialize(self)
	combat_state_machine.set_active(true)
	
	combat_state_machine.add_transition(ranged_mode, melee_mode, &"melee_mode")
	combat_state_machine.add_transition(melee_mode, ranged_mode, &"ranged_mode")

	
func _process(_delta):
	if not cutscene_handler.actor_control_active or not qte_handler.actor_control_active:
		bt_player.active=false
		return
	ammo_count=turret.ammo_count
	dir = to_local(next)
	#if combat_state_machine.get_active_state()==melee_mode:
		#force_chase()
	if state_machine.get_active_state()==death or state_machine.get_active_state()==staggered or state_machine.get_active_state()==hit:
		hb_collision.disabled=true
		return
	elif state_machine.get_active_state()==idle:
		hb_collision.disabled=true
	vision_handler.handle_vision()
	if not attack_range.has_overlapping_bodies() and not attacking:
		bt_player.blackboard.set_var("within_range", false)
	#bt_player.blackboard.get_var("attack_mode"))
	attack_timer.one_shot=true
	counter_select()
	bt_player.blackboard.set_var("ammo",ammo_count)
	
	is_on_screen=on_screen.is_on_screen()
	#if not is_on_screen:
		#assert(bt_player.blackboard.get_var("attack_mode")==false)
	if Input.is_action_just_pressed("DEBUG_KEY"):
		test_function()
		
	if player.state_machine.get_active_state()==player.dodge_state:
		set_collision_mask_value(2, false)
	else:
		set_collision_mask_value(2, true)
		
	#player_behind_check()
		
	if health.health<=0:
		bt_player.blackboard.set_var("attack_mode", false)
		#bt_player.restart()
		bt_player.active=false
		if not death_cutscene:
			pass
		elif cutscene_handler.actor_control_active:
			assert(state_machine.get_active_state()==death)
		assert(bt_player.active==false)
		
func _physics_process(delta):
	##FOR TESTING REMOVE LATER

##	END OF TEST
	if not cutscene_handler.actor_control_active or not qte_handler.actor_control_active:
		apply_gravity(delta)
		#cutscene_acceleration(cutscene_handler.cutscene_dir, delta)
		move_and_slide()
		return
	
	
	knockback = lerp(knockback, Vector2.ZERO, 0.1)
	
	if  state_machine.get_active_state()==hit or state_machine.get_active_state()==staggered:
		#hb_collison.disabled=true
		velocity.y += gravity * delta
		#velocity.x=0
		move_and_slide()
		return
	elif state_machine.get_active_state()==dying:
		death_handler.dying()
	elif state_machine.get_active_state()==death :
		hb_collision.disabled=true
		return
	#melee_range_failsafe()
	#counter_attack()
	# Add the gravity.
	if not is_on_floor():
		if state_machine.get_active_state()==death:
			velocity.y=0
		else:
			velocity.y += gravity * delta
	else:
		dying.blackboard.set_var("hit_the_floor", true)
		
	if state_machine.get_active_state()==staggered and parry_timer.time_left>0.0:
		state_machine.change_active_state(staggered)
		
	#handle_movement()
	if state_machine.get_active_state()==chasing:
		velocity.x = current_speed + knockback.x
	else:
		if state_machine.get_active_state()!=attack:
			velocity.x= knockback.x
		else:
			pass

	
	move_and_slide()
	#if player_right:
		#animated_sprite_2d.flip_h=false
	#else:
		#animated_sprite_2d.flip_h=true

func teleport_counter():
	state_machine.dispatch(&"teleport_counter")
	
func teleport_atk():
	state_machine.dispatch(&"teleport_atk")
	
func apply_gravity(delta : float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
func handle_vision():
	vision_handler.handle_vision()

		
func target_lock():
	Events.unlock_from.emit()
	target_lock_node.target_lock()
	locked_on=true
	

func chase():
	#set_state(current_state, States.CHASE)
	state_machine.dispatch(&"start_chase")
	melee_attack_manager.reset_combo()
	#state_machine.change_active_state(chasing)
	
func force_chase():
	
	if not is_on_screen and vision_handler.always_on==true and state_machine.get_active_state()!=chasing:
		state_machine.change_active_state(chasing)

func health_bar():
	h_bar.text=str(health.health, " : ammo:",turret.ammo_count , " : STG: ", stagger.stagger)

func makepath() -> void:
	nav_agent.target_position = player.global_position
	

		
func get_player_state(_player: PlayerEntity) -> void:
	player_state=_player.get_state_enum()
	
func get_player_relative_loc():
	if player.global_position.x>global_position.x:
		player_right=true
	else:
		player_right=false

func player_behind_check():
	if (player_right and animated_sprite_2d.scale.x>0) or\
	 (not player_right and animated_sprite_2d.scale.x<0):
		hit_box.active=false
		hurt_box.weakpoint=true
		player_behind=true
	else:
		player_behind=false
		hurt_box.weakpoint=false



func get_width() -> int:
	return collision_shape_2d.get_shape().radius
func get_height() -> int:
	return collision_shape_2d.get_shape().radius+10

func teleport_away() -> void:
	var _tele_left := -100
	var _tele_right := 100
	var _tele_height := 80
	
	if player_right:
		global_position=teleport_handler.teleport((global_position.x+_tele_left), (global_position.y- _tele_height), global_position)
	else:
		global_position=teleport_handler.teleport((global_position.x+_tele_right), (global_position.y- _tele_height), global_position)
		
func teleport_to(front : bool) -> void:
#	X-axis offset so objects ends up consistantly in front or behind of player
	var offset:= func():
		if front: return 10
		else: return -10
	
	print_debug(player.global_position)
	if player_right:
		print_debug(global_position)
		global_position=teleport_handler.teleport(teleport_helper_raycast.target_position.x-offset.call(),\
		 teleport_helper_raycast.target_position.y,\
		 global_position)
		#global_position.x+offset.call()
		print_debug(global_position)
	else:
		print_debug(global_position)
		global_position=teleport_handler.teleport(teleport_helper_raycast.target_position.x+offset.call(),\
		 teleport_helper_raycast.target_position.y,\
		 global_position)
		#global_position.y+offset.call()
		print_debug(global_position)

func dodge_counter() -> void:
	var _dodge_chance = randi_range(0,1)
	if _dodge_chance==0:
		dodge.dodge_anim="dodge_forward"
		dodge.dodge_setup(150, 0)
	else:
		dodge.dodge_anim="dodge_back"
		dodge.dodge_setup(-400, 0)
	#bt_player.blackboard.set_var("dodge", true)
	bt_player.blackboard.set_var("staggered", true)
	state_machine.dispatch(&"dodge_back")

func dodge_end() -> void:
	#bt_player.blackboard.set_var("dodge", false)
	bt_player.blackboard.set_var("staggered", false)
	state_machine.dispatch(&"dodge_end")
	bt_player.blackboard.set_var("within_range", true)
	set_collision_layer_value(15, true)
	bt_player.restart()
	melee_attack_manager.atk_resume_helper()


func _on_animation_player_animation_started(anim_name: StringName) -> void:
	
	if anim_name.substr(0, 3)=="atk":
		hit_box.active=true
		movement_handler.face_player_active=false
		if anim_name!="atk_dash":
			return
			print_debug(anim_name)
		print_debug(anim_name)
		if anim_name=="atk_counter":
			hit_stop_dur=0.2
		else:
			hit_stop_dur=0.1
		bt_player.active=false
		attacking=true
	elif anim_name== "dodge":
		state_machine.dispatch(&"dodge_end")
		
	elif anim_name=="flashback_lvl_cutscenes/first_mini_boss_kill":
		print_debug("w0t")
	else:
		pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	#print_debug(anim_name)
	if anim_name.substr(0, 3)=="atk":
		if anim_name=="atk_counter":
			bt_player.blackboard.set_var("atk_counter", false)
			melee_attack_manager.reset_combo()
		elif anim_name=="atk_dash":
			bt_player.blackboard.set_var("dash_hit", true)
			dash_attacking=false
		else:
			if melee_attack_manager.heavy_attack_counter():
				if phases.get_active_state()==phase_2:
					melee_attack_manager.set_atk_type("atk_4")
				else:
					melee_attack_manager.set_atk_type("atk_3")
			else:
				melee_attack_manager.next_combo()
			if state_machine.get_active_state()==clashed:
				bt_player.blackboard.set_var("staggered", false)
		bt_player.blackboard.set_var(melee_attack_manager.get_combo(), true)
		attack_timer.start(0.3)
		bt_player.active=true
		bt_player.blackboard.set_var("staggered", false)
		attacking=false
		if attack_missed:
			var _heavy_atk_min := melee_attack_manager.heavy_atk_min
			_heavy_atk_min -=10
			melee_attack_manager.set_heavy_atk_min(_heavy_atk_min)
			if bt_player.blackboard.get_var("within_range"):
				state_machine.dispatch(&"start_chase")
			else:
				state_machine.dispatch(&"resume_attack")
		if state_machine.get_active_state()==clashed:
			state_machine.dispatch(&"resume_attack")
		attack_missed=false
		movement_handler.face_player_active=true
		movement_handler.face_player()
	elif anim_name=="dodge":
		state_machine.dispatch(&"dodge_end")
	elif anim_name=="clashed":
		if stagger.stagger>0:
			clash_counter()
	elif anim_name=="hit" or anim_name=="hit_quick_recover":
		state_machine.dispatch(&"hit_recover")
	elif anim_name=="atk_dash":
		bt_player.blackboard.set_var("attack_dash", false)
	#elif "teleport_start":
			#print_debug(global_position)
	#elif "teleport_end":
			#print_debug(global_position)
	elif anim_name== "flashback_lvl_cutscenes/miniboss_hallway_death":
		death_on_cutscene()
	else:
		pass


func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and state_machine.get_active_state()!=staggered:
		bt_player.blackboard.set_var("within_range", true)
		#set_state(current_state, States.ATTACK)
		if player.attack_state.get_active_state()==player.dash_attack or player.attack_state.get_active_state()==player.attack_closer:
			bt_player.blackboard.set_var("melee_mode", true)
			bt_player.blackboard.set_var("counter_kick_flag", false)
			bt_player.blackboard.set_var("counter_attack", true)
			bt_player.blackboard.set_var("attack_dash", true)
			dash_attacking=true
		else:
			state_machine.dispatch(&"start_attack")
		

func _on_attack_range_body_exited(body: Node2D) -> void:
	if changing_phase:
		return
	elif attacking:
		attack_missed=true
		return
		
	elif body.is_in_group("player") and not animation_player.is_playing() and state_machine.get_active_state()!=staggered:
		bt_player.blackboard.set_var("within_range", false)
		#set_state(current_state, States.CHASE)
		state_machine.dispatch(&"start_chase")
		
func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("sp_atk_default"):
		if player.state_machine.get_active_state()==player.flip_state or player.state_machine.get_previous_active_state()==player.flip_state:
			Events.allied_enemy_hit.emit()
		if animated_sprite_2d.flip_h:
			knockback.x=50
		else:
			knockback.x=-50
		stagger.stagger -= player.sp_atk_dmg*player.clash_power.clash_power
		
		



func _on_navigation_timer_timeout() -> void:
	makepath()
	next_y=nav_agent.get_next_path_position().y
	next_x=nav_agent.get_next_path_position().x
	next=nav_agent.get_next_path_position()


func _on_stagger_staggered() -> void:
	#set_state(current_state, States.STAGGERED)
	#bt_player.blackboard.set_var("staggered", true)
	bt_player.restart()
	parry_timer.start(3)
	hit_stop.hit_stop(0.01, 0.5)
	#hb_collision.disabled=true
	hb_collision.call_deferred("set_disabled", true)
	hurt_box_collision.set_deferred("disabled", false)
	hurt_box.active=true
	state_machine.dispatch(&"staggered")
	Events.camera_shake.emit(2,20)


func _on_parry_timer_timeout() -> void:
	if state_machine.get_active_state()==staggered:
		print_debug(phases.get_active_state())
		if phases.get_active_state()==phase_1:
			state_machine.dispatch(&"stagger_recover")
		elif phases.get_active_state()==phase_2:
			state_machine.dispatch(&"teleport_recover")
		phases_handler.phase_change(health.health)
	elif state_machine.get_active_state()==hit:
		state_machine.dispatch(&"hit_recover")
	movement_handler.active=true
	hurt_box.set_damage_mulitplyer(1)

func adjust_counter():
	
	if not counter_flag:
		if counter_kick_chance <100:
			counter_kick_chance +=10
	else:
		
		if counter_kick_chance > 10:
			counter_kick_chance -=10
		
func counter_select()->void:
	if ammo_count>0:
		if randi_range(0,100)<=counter_kick_chance:
			bt_player.blackboard.set_var("counter_kick_flag", true)
			counter_flag=true
		else:
			bt_player.blackboard.set_var("counter_kick_flag", false)
			counter_flag=false
	else:
		
		bt_player.blackboard.set_var("counter_kick_flag", true)
		counter_flag=true
		

	
func rapid_shoot(value : bool)->void:
	turret.multi_shot=value

func alerted() -> void :
	if changing_phase:
		return
	else:
		print_debug("alerted!")
		vision_handler.always_on=true
		if on_screen.is_on_screen():
			state_machine.dispatch(&"attack_mode")
			bt_player.blackboard.set_var("attack_mode", true)
		else:
			bt_player.blackboard.set_var("attack_mode", false)
			state_machine.dispatch(&"start_chase")

func _on_hurt_box_received_damage(damage: int) -> void:
	
	if health.health<=phases_handler.phases.get(phases_handler.cur_phase-1):
		hit_stop.hit_stop(0.2, 2)
	
	if state_machine.get_active_state()!=staggered and\
	 state_machine.get_active_state()!=launch and\
	 state_machine.get_active_state()!=falling:
		phases_handler.phase_change(health.health)
	if changing_phase:
		
		return
	else:
		if clash_mult>1:
			stagger.stagger-=(clash_mult-1)
		if player.state_machine.get_active_state()==player.flip_state or player.state_machine.get_previous_active_state()==player.flip_state:
			Events.allied_enemy_hit.emit()
		
		bt_player.restart()
		if state_machine.get_active_state()==death:
			return
		health.set_temporary_immortality(0.2)
		if damage<=health.health:
			if state_machine.get_active_state()!=staggered:
				parry_timer.start(0.5)
				if player_behind:
					hit.hit_anim="hit_weakpoint"
				elif stagger.stagger>1:
					hit.hit_anim="hit_quick_recover"
				else:
					hit.hit_anim="hit"
				state_machine.dispatch(&"hit")
			hit_stop.hit_stop(0.05,0.25)
			#set_state(current_state, States.HIT)
			gpu_particles_2d.emitting=true
			melee_attack_manager.atk_resume_helper()
			bt_player.active=true
		else:
			print_debug("kill shot")
		

func _on_hurt_box_bullet_hit(_damage: int) -> void:
	if state_machine.get_active_state()==staggered:
		launch.launch_strength=20.0
		launch.knock_back_strength=80.0
		state_machine.dispatch(&"launched")

func _on_health_health_depleted() -> void:
	parry_timer.stop()
	hb_collision.disabled=true
	movement_handler.active=false
	animated_sprite_2d.scale.x = 1
	movement_handler.active=false
	if player_right:
		knockback.x=-250
	else:
		knockback.x=250
	jump_handler.handle_jump(0.2)
	if not death_cutscene:
		death_handler.death()
	else:
		animation_player.stop()
		bt_player.blackboard.set_var("attack_mode", false)
		bt_player.restart()
		bt_player.active=false
		Events.unlock_from.emit()
		Events.boss_died.emit("miniboss_hallway_death")
		Events.global_flag_trigger.emit("miniboss_hallway_death")
		bt_player.active=false
		set_deferred("visible", false)


func _on_attack_timer_timeout() -> void:
	#"begin move")
	if state_machine.get_active_state()==staggered:
		return
	if bt_player.blackboard.get_var("within_range")==true:
		#set_state(current_state, States.ATTACK)
		state_machine.dispatch(&"start_attack")
	else:
		#set_state(current_state, States.CHASE)
		state_machine.dispatch(&"start_chase")


func _on_turret_shoot_bullet() -> void:
	shoot_handler.shoot_bullet()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if not player_found:
		vision_handler.active=false
	if state_machine.get_active_state()==death:
		queue_free()

 
func _on_limbo_hsm_active_state_changed(current: LimboState, previous: LimboState) -> void:
	print_debug(current)
	if current==jump:
		if previous==attack:
			print_debug("down attack")
	if current==teleport_and_shoot:
		print_debug(current)

func _on_attack_entered() -> void:
	bt_player.blackboard.set_var("attack_mode", true)

func _on_attack_updated(delta: float) -> void:

	if hit_box.active:
		player_behind_check()
		if player_behind:
			hurt_box.active=true
		else:
			hurt_box.active=false
		
	
		
func _on_hit_box_area_entered(_area: Area2D) -> void:
	hit_stop.hit_stop(0.05,0.1)
	if dash_attacking:
		animation_player.play_section_with_markers(&"atk_dash", &"atk_dash_hit")
		hit_stop.hit_stop(0.1,3)
		


func _on_hit_box_parried() -> void:
	parried=true
	state_machine.dispatch(&"counter")
	bt_player.restart()
	bt_player.active=false
	

func _on_hit_entered() -> void:
	#bt_player.blackboard.set_var("hit", true)
	bt_player.blackboard.set_var("staggered", true)
	if hit.hit_anim=="hit":
		velocity.x=0
		parry_timer.start(0.1)
	else:
		if player_right:
			velocity.x=-100
		else:
			velocity.x=100

func _on_hit_exited() -> void:
	#bt_player.blackboard.set_var("hit", false)
	bt_player.blackboard.set_var("staggered", false)

func _on_hit_updated(delta: float) -> void:

	move_and_slide()

func _on_kick_counter_exited() -> void:
	bt_player.active=true
	hurt_box_collision.disabled=false


func _on_counter_exited() -> void:
	bt_player.active=true
	hurt_box_collision.disabled=false


func _on_clash_timer_timeout() -> void:
	clash_mult=1


func _on_counter_updated(_delta: float) -> void:
	if player.state_machine.get_active_state()!=player.parry_success_state and counter_timer.is_stopped():
		state_machine.dispatch(&"counter_end")


func _on_staggered_exited() -> void:
	bt_player.blackboard.set_var("staggered", false)
	bt_player.active=true
	phases_handler.phase_change(health.health)






func _on_bullet_detection_bullet_detected() -> void:
	print_debug(state_machine.get_active_state())
	state_machine.dispatch(&"bullet_dodge")


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	vision_handler.active=true
	if vision_handler.player_found or vision_handler.always_on:
		state_machine.dispatch(&"attack_mode")
		bt_player.blackboard.set_var("attack_mode", true)


func _on_bullet_detection_body_entered(_body: Node2D) -> void:
	pass # Replace with function body.


func _on_bulletdodge_entered() -> void:
	bt_player.active=false


func _on_bulletdodge_exited() -> void:
	bt_player.active=true
	


func _on_dying_entered() -> void:
	boss_ui.deactivate_boss_ui()


func _on_phase_2_entered() -> void:
	launch.air_time=0.5
	bt_player.blackboard.set_var("Phase2Active", true)
	combat_state_change_handler.ranged_dist=1000
	bt_player.blackboard.set_var("melee_mode", true)
	#bt_player.blackboard.set_var("attack_mode", false)
	#bt_player.restart()
	#state_machine.change_active_state(teleport_and_shoot)
	#assert(state_machine.get_active_state()==teleport_and_shoot)
	#bt_player.blackboard.set_var("attack_mode", true)
	#state_machine.change_active_state(idle)
	#counter_sm.add_transition(begin_counter, teleport_and_shoot, &"teleport_counter")
	#state_machine.add_transition(counter_sm, attack, teleport_and_shoot.success_event)
	#changing_phase=false
	#state_machine.change_active_state(begin_counter)
	#counter_sm.dispatch(&"teleport_counter")


func _on_phases_handler_next_phase() -> void:
	#hurt_box_collision.disabled=true
	bt_player.blackboard.set_var("staggered", false)
	#bt_player.blackboard.set_var("launched", false)
	#bt_player.blackboard.set_var("falling", false)
	hurt_box_collision.call_deferred("set_disabled", true)
	changing_phase=true
	bt_player.blackboard.set_var("attack_mode", false)
	bt_player.restart()
	state_machine.dispatch(&"begin_next_phase")
	


func _on_phasetransition_entered() -> void:
	
	state_machine.add_transition(attack, teleport_and_shoot, &"teleport_counter")
	state_machine.add_transition(clashed, teleport_and_shoot, &"teleport_clash")
	state_machine.add_transition(staggered, teleport_and_shoot, &"teleport_recover")
	state_machine.add_transition(chasing, teleport_and_hit, &"teleport_atk")
	state_machine.add_transition(clashed, teleport_and_hit, &"teleport_atk")
	
	state_machine.add_transition(teleport_and_shoot, attack, teleport_and_shoot.success_event)
	state_machine.add_transition(teleport_and_hit, attack, teleport_and_hit.success_event)
	melee_attack_manager.combo_max=4



func _on_phasetransition_exited() -> void:
	changing_phase=false
	bt_player.blackboard.set_var("counter_attack", false)
	hurt_box_collision.disabled=false
	phases.dispatch(&"next_phase")


func _on_phasetransition_updated(delta: float) -> void:
	
	assert(bt_player.blackboard.get_var("attack_mode")==false)


func _on_teleport_and_shoot_entered() -> void:
	hurt_box.set_collision_layer_value(7, false)
	print_debug("worked")


func _on_staggered_entered() -> void:
	pass
	#stagger_timer.start(3)


func _on_teleport_and_shoot_exited() -> void:
	hurt_box.set_collision_layer_value(7, true)
	hurt_box.active=true
	teleport_helper_raycast.target_position=Vector2(0,50)

func death_on_cutscene() -> void:
	state_machine.change_active_state(death)

func _on_death_entered() -> void:
	bt_player.active=false
	animation_player.play("dead")


func _on_death_updated(delta: float) -> void:
	bt_player.active=false
	animation_player.play("dead")

func boss_reset() -> void:
	process_mode=Node.PROCESS_MODE_INHERIT
	vision_handler.active=vision_active
	vision_handler.stay_on=vision_stay_on
	vision_handler.always_on=vision_always_on
	combat_state_change_handler.ranged_dist=100
	bt_player.blackboard.set_var("attack_mode", false)
	bt_player.blackboard.set_var("melee_mode", false)
	bt_player.blackboard.set_var("ranged_mode", true)
	bt_player.blackboard.set_var("within_range", false)
	bt_player.blackboard.set_var("counter_attack", false)
	bt_player.blackboard.set_var("counter_kick_flag", false)
	bt_player.blackboard.set_var("staggered", false)
	bt_player.blackboard.set_var("Phase2Active", false)
	dying.blackboard.set_var("hit_the_floor", false)
	bt_player.restart()
	is_on_screen=false
	bt_player.active=false
	animation_player.stop()
	state_machine.change_active_state(idle)
	state_machine.restart()
	combat_state_machine.change_active_state(ranged_mode)
	combat_state_machine.restart()
	phases.change_active_state(phase_1)
	phases.restart()
	health.health=health.max_health
	stagger.stagger=stagger.max_stagger
	movement_handler.active=false
	phases_handler.reset_phases()
	#process_mode=Node.PROCESS_MODE_DISABLED
	set_process(false)
	set_physics_process(false)
	state_machine.remove_transition(attack, &"teleport_counter")
	state_machine.remove_transition(staggered, &"teleport_recover")
	state_machine.remove_transition(chasing, &"teleport_atk")
	state_machine.remove_transition(teleport_and_shoot, teleport_and_shoot.success_event)
	state_machine.remove_transition(teleport_and_hit, teleport_and_hit.success_event)
	teleport_handler.teleport_dir_helper_rc.global_position=global_position
	teleport_handler.teleport_dir_helper_rc.top_level=false
	boss_reloaded.emit()
	#_ready()
	
func game_over() -> void:
	#boss_ui.visible=false
	boss_ui.set_deferred("visible", false)
	state_machine.change_active_state(idle)
	#process_mode=Node.PROCESS_MODE_DISABLED

func boss_activate() -> void:
	process_mode=Node.PROCESS_MODE_INHERIT
	set_process(true)
	set_physics_process(true)
	bt_player.active=true


func _on_child_entered_tree(node: Node) -> void:
	pass # Replace with function body.


func _on_boss_reloaded() -> void:
	assert(is_on_screen==false)



func _on_teleport_and_hit_updated(delta: float) -> void:
	#teleport_helper_raycast.look_at(Vector2(player.global_position.x, player.global_position.y-100))
	teleport_helper_raycast.target_position=player.global_position-teleport_helper_raycast.global_position
	print_debug(player.global_position, " ", teleport_helper_raycast.target_position)

func _on_teleport_and_hit_exited() -> void:
	hurt_box.active=true

func _on_teleport_and_hit_entered() -> void:
	pass


func _on_hurt_box_launched() -> void:
	state_machine.change_active_state(launch)
		


func _on_launch_timer_timeout() -> void:
	if phases.get_active_state()==phase_2:
		teleport_counter()
	else:
		state_machine.dispatch(&"falling")


func _on_hit_box_clashed() -> void:
	hit_stop.hit_stop(0.01, 1)
	print_debug("clashed!")
	if hit_box.heavy_attack:
		return
	else:
		var _heavy_atk_min := melee_attack_manager.heavy_atk_min
		_heavy_atk_min +=5
		melee_attack_manager.set_heavy_atk_min(_heavy_atk_min)
	
	stagger.stagger-=1
	if player_right:
		knockback.x=-200
	else:
		knockback.x=200
	if dash_attacking:
		return
	#bt_player.blackboard.set_var("staggered", true)
	state_machine.dispatch(&"clashed")

func _on_clashed_entered() -> void:
	#bt_player.blackboard.set_var("staggered", true)
	print_debug(animation_player.current_animation_position)
	var _current_atk : String = animation_player.current_animation
	var _atk_clash_anim : String = _current_atk+"_connect"
	var _atk_clash_anim_end : String = _current_atk+"_end"
	var _atk_connect := animation_player.get_animation(_current_atk).get_marker_time(_atk_clash_anim)
	#animation_player.seek(_atk_connect, true, false)
	print_debug(_atk_clash_anim)
	attacking=true
	#animation_player.seek(_atk_connect, true, false)
	animation_player.call_deferred("seek", _atk_connect, true, false)
	#animation_player.play_section_with_markers(_current_atk, _atk_clash_anim, _atk_clash_anim_end)
	print_debug(animation_player.current_animation_position)
	AudioStreamManager.play(SoundFx.SOCAPEX_SWORDSMALL_2)


func _on_clashed_exited() -> void:
	bt_player.blackboard.set_var("staggered", false)

func clash_counter() -> void:
	if phases.get_active_state()==phase_1:
		melee_attack_manager.atk_resume_helper()
		state_machine.dispatch(&"resume_attack")
	else:
		if randi_range(0,1)==0:
			state_machine.dispatch(&"teleport_hit")
		else:
			state_machine.dispatch(&"teleport_shoot")


func _on_land_landed() -> void:
	state_machine.dispatch(&"resume_attack")
	phases_handler.phase_change(health.health)


func _on_attack_exited() -> void:
	movement_handler.face_player_active=true
