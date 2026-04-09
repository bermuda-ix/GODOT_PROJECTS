class_name SoldierEnemy
extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -400.0
const BALL_PROCETILE = preload("res://Component/ball_procetile.tscn")
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
@onready var vfx_player: AnimationPlayer = $AnimationPlayer/VFXPlayer
@onready var audio_fx: AudioStreamPlayer2D = $AnimatedSprite2D/VFXSprite/AudioFX
@onready var nav_agent = $NavigationAgent2D
@onready var jump_timer = $JumpTimer
@onready var movement_handler: MovementHandler = $MovementHandler
@onready var knocked_back : bool = false
@onready var teleport_handler: TeleportHandler = $TeleportHandler


#Cutscene Vars
@onready var speed: Label = $Speed
@onready var cutscene_handler: CutsceneHandler = $CutsceneHandler
@onready var qte_handler: QTEHandler = $QTEHandler


@export var drop = preload("res://heart.tscn")
@onready var death_timer = $DeathTimer
@export var explode = preload("res://Component/explosion.tscn")

@onready var floor_jump_check_right = $JumpChecks/FloorJumpCheckRight as RayCast2D
@onready var floor_jump_check_left = $JumpChecks/FloorJumpCheckLeft as RayCast2D
@onready var gap_check_left = $JumpChecks/GapCheckLeft as RayCast2D
@onready var gap_check_right = $JumpChecks/GapCheckRight as RayCast2D
@onready var leap_up_check_left = $JumpChecks/LeapUpCheckLeft
@onready var leap_up_check_right = $JumpChecks/LeapUpCheckRight

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
@onready var on_screen: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@export var counter_kick_chance : int = 0
@onready var counter_flag : bool = false
@onready var locked_on : bool = false
@onready var clash_power: ClashPower = $ClashPower
@onready var clash_mult = clash_power.clash_power
@onready var clash_timer: Timer = $ClashTimer


var current_speed : float = 40.0
var prev_speed : float = 40.0
var acceleration : float = 800.0
var player_found : bool = true
var player : PlayerEntity = null
var jump_velocity = JUMP_VELOCITY
var knockback : Vector2 = Vector2.ZERO
var parried : bool = false 
var attacking : bool = false
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

@onready var hit_stop: HitStop = $HitStop
@onready var hit_stop_dur = 0.1

@onready var death_handler: DeathHandler = $DeathHandler

#State Machine
@onready var state_machine : LimboHSM = $LimboHSM

#states
@onready var idle: Idle = $LimboHSM/IDLE
@onready var chasing: Chasing = $LimboHSM/CHASING
@onready var jump: Jump = $LimboHSM/JUMP
@onready var death: Death = $LimboHSM/DEATH
@onready var attack: Attack = $LimboHSM/ATTACK
@onready var shooting: Shooting = $LimboHSM/SHOOTING
@onready var dodge: Dodge = $LimboHSM/DODGE
@onready var bulletdodge: BulletDodge = $LimboHSM/BULLETDODGE
@onready var hit: Hit = $LimboHSM/HIT
@onready var staggered: Staggered = $LimboHSM/STAGGERED
@onready var dying: BTState = $LimboHSM/DYING
@onready var launch: Launch = $LimboHSM/Launch
@onready var falling: LimboState = $LimboHSM/Falling
@onready var landed: LimboState = $LimboHSM/Landed
@onready var clashed: Clashed = $LimboHSM/Clashed
@onready var teleport: LimboState = $LimboHSM/Teleport




#Counter States
@onready var counter_sm: LimboHSM = $LimboHSM/COUNTER
@onready var begin_counter: LimboState = $LimboHSM/COUNTER/BeginCounter
@onready var kick_counter: LimboState = $LimboHSM/COUNTER/KickCounter


@onready var combat_state_machine: LimboHSM = $CombatStateMachine
@onready var ranged_mode: LimboState = $CombatStateMachine/RANGED
@onready var melee_mode: LimboState = $CombatStateMachine/MELEE

@onready var ammo_count

var is_on_screen : bool


enum CombatStates{
	RANGED,
	MELEE,
	}
	
var current_combat_state = CombatStates.RANGED
var prev_combat_state = CombatStates.RANGED
var combat_state : String = "RANGED"
var player_state : LimboState
	
func _ready():
	player = get_tree().get_first_node_in_group("player")
	#set_state(current_state, States.CHASE)
	ammo_count=turret.ammo_count
	bullet = BALL_PROCETILE
	animation_player.play("idle")
	state="guard"
	next=nav_agent.get_next_path_position()
	bt_player.blackboard.set_var("attack_mode", false)
	bt_player.blackboard.set_var("melee_mode", false)
	bt_player.blackboard.set_var("ranged_mode", true)
	bt_player.blackboard.set_var("within_range", false)
	bt_player.blackboard.set_var("counter_attack", false)
	bt_player.blackboard.set_var("counter_kick_flag", false)
	bt_player.blackboard.set_var("staggered", false)
	bt_player.blackboard.set_var("atk_1", true)
	dying.blackboard.set_var("hit_the_floor", false)
	#turret.setup(0.2)
	#boss_ui.activate_boss_ui()
	#boss_ui.set_max_boss_health(health.max_health)
	#boss_ui.set_boss_health(health.health)
	turret.shoot_timer.paused=true
	_init_state_machine()
	_init_combat_state_machine()
	_init_counter_state_machine()
	hurt_box.set_damage_mulitplyer(1)
	Events.allied_enemy_hit.connect(adjust_counter)
	
	player_tracking.target_position=Vector2(vision_handler.vision_range,0)
	if health.health<=0:
		queue_free()
	if always_active:
		alerted()
	
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
	state_machine.add_transition(launch, falling, &"falling")
	state_machine.add_transition(falling, landed, &"landed")
	state_machine.add_transition(landed, attack, &"resume_attack")
	
	state_machine.add_transition(attack, clashed, &"clashed")
	state_machine.add_transition(clashed, teleport, &"teleport")
	#state_machine.add_transition(clashed, dodge, &"dodge_back")
	
	
	state_machine.add_transition(state_machine.ANYSTATE, hit, &"hit")
	state_machine.add_transition(state_machine.ANYSTATE, dying, &"die")
	state_machine.add_transition(dying, death, dying.success_event)
	state_machine.add_transition(state_machine.ANYSTATE, staggered, &"staggered")
	
func _init_counter_state_machine():
	counter_sm.initial_state=begin_counter
	counter_sm.add_transition(begin_counter, kick_counter, &"kick_counter")


func _init_combat_state_machine():
	combat_state_machine.initial_state=ranged_mode
	combat_state_machine.initialize(self)
	combat_state_machine.set_active(true)
	
	combat_state_machine.add_transition(ranged_mode, melee_mode, &"melee_mode")
	combat_state_machine.add_transition(melee_mode, ranged_mode, &"ranged_mode")

	
func _process(_delta):
	if not cutscene_handler.actor_control_active or not qte_handler.actor_control_active:
		return
	ammo_count=turret.ammo_count
	#if health.health<=0 and (state_machine.get_active_state()!=death or state_machine.get_active_state()!=dying):
		#state_machine.dispatch(&"die")
	##FOR TESTING REMOVE LATER
	##current_state=States.GUARD
	##if current_state==States.GUARD:
		##return
	#if state_machine.get_active_state() == idle:
		#return
##	END OF TEST
	#movement_handler.dir)
	dir = to_local(next)
	force_chase()
	if state_machine.get_active_state()==death or state_machine.get_active_state()==staggered or state_machine.get_active_state()==hit:
		hb_collision.disabled=true
		return
	elif state_machine.get_active_state()==idle:
		hb_collision.disabled=true
	#health_bar()
	#track_player()
	#combat_state_change()
	vision_handler.handle_vision()
	if not attack_range.has_overlapping_bodies():
		bt_player.blackboard.set_var("within_range", false)
	#bt_player.blackboard.get_var("attack_mode"))
	attack_timer.one_shot=true
	counter_select()
	bt_player.blackboard.set_var("ammo",ammo_count)
	#get_player_state(player)
	#on_screen.is_on_screen()
		#print_debug(parry_timer.time_left)

func _physics_process(delta):
	##FOR TESTING REMOVE LATER
	##current_state=States.GUARD
	##if current_state==States.GUARD:
		##return
	#if state_machine.get_active_state() == idle:
		#return
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
		velocity.x=0
		move_and_slide()
		return
	elif state_machine.get_active_state()==dying:
		death_handler.dying()
	elif state_machine.get_active_state()==death :
		hb_collision.disabled=true
		return
	#melee_range_failsafe()
	if state_machine.get_active_state()!=launch:
		if is_on_floor():
			bt_player.blackboard.set_var("launched", false)
			bt_player.blackboard.set_var("falling", false)
	# Add the gravity.
	if not is_on_floor():
		if state_machine.get_active_state()==death:
			velocity.y=0
		elif state_machine.get_active_state()!=launch:
			velocity.y += gravity * delta
	else:
		dying.blackboard.set_var("hit_the_floor", true)
		
	if state_machine.get_active_state()==staggered and parry_timer.time_left>0.0 and state_machine.get_active_state()!=launch:
		state_machine.change_active_state(staggered)
		
	#handle_movement()
	if state_machine.get_active_state()==chasing:
		velocity.x = current_speed + knockback.x
	else:
		velocity.x= knockback.x
	
	move_and_slide()
	
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
	#state_machine.change_active_state(chasing)
	
func force_chase():
	var is_on_screen=on_screen.is_on_screen()
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



func get_width() -> int:
	return collision_shape_2d.get_shape().radius
func get_height() -> int:
	return collision_shape_2d.get_shape().radius+10

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	if anim_name.substr(0, 3)=="atk":
		hit_box.active=true
		if anim_name=="atk_counter":
			hit_stop_dur=0.2
		else:
			hit_stop_dur=0.1
		bt_player.active=false
		attacking=true
	elif anim_name== "dodge":
		state_machine.dispatch(&"dodge_end")
		

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name.substr(0, 3)=="atk":
		hit_box.heavy_attack=false
		if anim_name=="atk_counter":
			bt_player.blackboard.set_var("atk_counter", false)
			melee_attack_manager.reset_combo()
		else:
			melee_attack_manager.next_combo()
		bt_player.blackboard.set_var(melee_attack_manager.get_combo(), true)
		attack_timer.start(0.3)
		bt_player.active=true
		attacking=false
	elif anim_name=="clashed":
		state_machine.dispatch(&"teleport")
		
	elif anim_name=="dodge":
		state_machine.dispatch(&"dodge_end")
		bt_player.active=true
			

func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and state_machine.get_active_state()!=staggered:
		bt_player.blackboard.set_var("within_range", true)
		#set_state(current_state, States.ATTACK)
		state_machine.dispatch(&"start_attack")

func _on_attack_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and not animation_player.is_playing() and state_machine.get_active_state()!=staggered:
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
	bt_player.blackboard.set_var("staggered", true)
	bt_player.restart()
	parry_timer.start(3)
	melee_attack_manager.reset_combo()
	hb_collision.set_deferred("disabled", true)
	hurt_box_collision.set_deferred("disabled", false)
	hurt_box.set_damage_mulitplyer(3)
	if state_machine.get_active_state()!=launch:
		state_machine.dispatch(&"staggered")
	Events.camera_shake.emit(2,20)


func _on_parry_timer_timeout() -> void:
	if state_machine.get_active_state()==staggered:
		state_machine.dispatch(&"stagger_recover")
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
	print_debug("alerted!")
	vision_handler.always_on=true
	if on_screen.is_on_screen():
		state_machine.dispatch(&"attack_mode")
		bt_player.blackboard.set_var("attack_mode", true)
	else:
		bt_player.blackboard.set_var("attack_mode", false)
		state_machine.dispatch(&"start_chase")

func _on_hurt_box_received_damage(damage: int) -> void:
	
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
			state_machine.dispatch(&"hit")
		else:
			animation_player.play("hit")
			AudioStreamManager.play(SoundFx.SOCAPEX_NEW_HITS_2)
		hit_stop.hit_stop(0.05,0.25)
		#set_state(current_state, States.HIT)
		gpu_particles_2d.emitting=true
		melee_attack_manager.atk_resume_helper()
		bt_player.active=true
	else:
		print_debug("kill shot")
		


func _on_health_health_depleted() -> void:
	parry_timer.stop()
	hb_collision.set_deferred("disabled", true)	
	movement_handler.active=false
	animated_sprite_2d.scale.x = 1
	movement_handler.active=false
	if player_right:
		knockback.x=-250
	else:
		knockback.x=250
	jump_handler.handle_jump(0.2)
	death_handler.death()
	
	


func _on_attack_timer_timeout() -> void:
	#"begin move")
	if state_machine.get_active_state()==staggered:
		return
	if bt_player.blackboard.get_var("within_range")==true:
		#set_state(current_state, States.ATTACK)
		state_machine.dispatch(&"start_attack")
	else:
		#set_state(current_state, States.CHASE)
		if attacking:
			return
		else:
			state_machine.dispatch(&"start_chase")


func _on_turret_shoot_bullet() -> void:
	#var bullet_inst = bullet.instantiate()
	#bullet_inst.set_speed(400.0)
	##bullet_inst.set_accel(50.0)
	##bullet_inst.tracking_time=0.01
	#bullet_inst.dir = (turret.player_tracker.target_position).normalized()
	#bullet_inst.spawnPos = Vector2(turret.global_position.x, turret.global_position.y)
	#bullet_inst.spawnRot = player_tracker_pivot.rotation_degrees
	##bullet_inst.dir)
	#
	#get_tree().current_scene.add_child(bullet_inst)
	shoot_handler.shoot_bullet()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	is_on_screen=false
	if not player_found:
		vision_handler.active=false
	if state_machine.get_active_state()==death:
		queue_free()


#func _on_stagger_timer_timeout() -> void:
	#bt_player.blackboard.set_var("attack_mode", true)
	#if state_machine.get_active_state()==staggered:
		#state_machine.dispatch(&"stagger_recover")
	#elif state_machine.get_active_state()==hit:
		#state_machine.dispatch(&"hit_recover")
	#movement_handler.active=true
	#state_machine.change_active_state(state_machine.get_previous_active_state())
	#set_state(current_state, prev_state)

 
func _on_limbo_hsm_active_state_changed(current: LimboState, previous: LimboState) -> void:
	#print_debug(current)
	#if current==chasing:
		#print_debug("chasing")
	if current==launch:
		print_debug("start here")
	if current==jump:
		if previous==attack:
			print_debug("down attack")

func _on_attack_entered() -> void:
	bt_player.blackboard.set_var("attack_mode", true)

func _on_hit_box_area_entered(_area: Area2D) -> void:
	print_debug(_area)
	hit_stop.hit_stop(0.05,0.1)
	#hit_box.active=false

func _on_hit_box_clashed() -> void:
	#animation_player.stop()
	#hit_box.active=false
	hit_stop.hit_stop(0.05, 0.5)
	print_debug("clashed!")
	stagger.stagger-=1
	if player_right:
		knockback.x=-200
	else:
		knockback.x=200
	state_machine.dispatch(&"clashed")
	


func _on_hit_box_clash_launch(_launch: float) -> void:
	pass # Replace with function body.


func _on_hit_box_clash_knock_back(_launch : float, _knockback : float, _impact_dir_right : bool) -> void:
	knocked_back=true
	var _total_stagger_damage = player.clash_power.clash_power+player.hitbox.damage
	if _total_stagger_damage>=stagger.stagger:
		if player_right:
			launch.knock_back_strength = -_knockback
		else:
			launch.knock_back_strength = _knockback
		launch.launch_strength=_launch
		state_machine.change_active_state(launch)
	else:
		if player_right:
			knockback.x=-_knockback*2
		else:
			knockback.x=_knockback*2

func _on_hit_box_parried() -> void:
	parried=true
	state_machine.dispatch(&"counter")
	bt_player.restart()
	bt_player.active=false


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


func _on_bullet_detection_bullet_detected() -> void:
	#print_debug(state_machine.get_active_state())
	state_machine.dispatch(&"bullet_dodge")


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	is_on_screen=true
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
	


func _on_hurt_box_launched(launch_strength: float) -> void:
	launch.launch_strength=launch_strength
	state_machine.change_active_state(launch)


func _on_hurt_box_knockback(_launch : float, _knockback : float, _impact_dir_right : bool) -> void:
	launch.launch_strength=_launch
	if _impact_dir_right:
		launch.knock_back_strength=-_knockback
	else:
		launch.knock_back_strength=-_knockback
	state_machine.change_active_state(launch)


func _on_launch_timer_timeout() -> void:
	state_machine.dispatch(&"falling")


func _on_falling_entered() -> void:
	animation_player.play("falling")
	bt_player.blackboard.set_var("launched", false)
	bt_player.blackboard.set_var("falling", true)


func _on_falling_exited() -> void:
	pass


func _on_falling_updated(delta: float) -> void:
	if is_on_floor():
		state_machine.dispatch(&"landed")


func _on_landed_entered() -> void:
	knocked_back=false
	animation_player.play("landed")


func _on_launch_entered() -> void:
	velocity.x=0
	current_speed=0
	bt_player.blackboard.set_var("launched", true)
	animation_player.play("launched")


func _on_landed_landed() -> void:
	bt_player.blackboard.set_var("launched", false)
	bt_player.blackboard.set_var("falling", false)
	state_machine.dispatch(&"resume_attack")


func _on_vfx_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="staggered_entered":
		vfx_player.play("staggered")


func _on_teleport_away_entered() -> void:
	animation_player.play("teleport_start")
	await animation_player.animation_finished
	teleport_handler.teleport_to(false, player.global_position)
	animation_player.play("teleport_end")
	await animation_player.animation_finished
	state_machine.dispatch(&"resume_attack")
