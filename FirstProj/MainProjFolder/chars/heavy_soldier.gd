extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const BALL_PROCETILE = preload("res://Component/ball_procetile.tscn")
# Get the gravity from the project settings to be synced with RigidBody nodes.
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#Basic
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
#Animation Player
@onready var animation_player: AnimationPlayer = $AnimationPlayer
#Target lock
@onready var target_lock_node: TargetLock = $TargetLock
#Visible on screen
@onready var on_screen: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

#Behaviour Tree Player
@onready var bt_player: BTPlayer = $BTPlayer
#Particles
@onready var gpu_particles_2d: GPUParticles2D = $AnimatedSprite2D/GPUParticles2D
@onready var gpu_particles_2d_2: GPUParticles2D = $AnimatedSprite2D/GPUParticles2D2
#On Screen

#Defense
@onready var health: Health = $Health
@onready var stagger: Stagger = $Stagger
@onready var hurt_box: HurtBox = $HurtBox
@onready var hurt_box_collision: CollisionShape2D = $HurtBox/hurt_box_collision
@onready var hit_stop: HitStop = $HitStop
@onready var hit_stop_dur = 0.0
@onready var parry_box: ParryBox = $ParryBox
@onready var parry_box_collision: CollisionShape2D = $ParryBox/CollisionShape2D


#Timers
@onready var navigation_timer: Timer = $NavigationTimer
@onready var jump_timer: Timer = $JumpTimer
@onready var parry_timer: Timer = $ParryTimer
@onready var chase_timer: Timer = $ChaseTimer
@onready var death_timer: Timer = $DeathTimer
@onready var dodge_timer: Timer = $DodgeTimer
@onready var attack_timer: Timer = $AttackTimer
@onready var stagger_timer: Timer = $StaggerTimer

#movement
@onready var movement_handler: MovementHandler = $MovementHandler
@onready var jump_handler: JumpHandler = $JumpHandler
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@export var jump_speed : float = 120.0
@export var chase_speed : float = 40.0

var current_speed : float = 0.0
var prev_speed : float = 00.0
var acceleration : float = 800.0
var jump_velocity = JUMP_VELOCITY
var knockback : Vector2 = Vector2.ZERO
var next_y
var next_x
var next
var dir

#Player Character Data
@onready var player_right : bool = false
@onready var player_tracking_handler: PlayerTrackingHandler = $PlayerTrackingHandler
@onready var vision_handler: VisionHandler = $VisionHandler
@onready var get_player_info_handler: GetPlayerInfoHandler = $GetPlayerInfoHandler
@onready var player_tracker_pivot: Node2D = $PlayerTrackerPivot
@onready var player_tracking: RayCast2D = $PlayerTrackerPivot/PlayerTracking
var player_found : bool = true
var player : PlayerEntity = null
var distance
var player_state : int

#States
@onready var state_machine: LimboHSM = $StateMachine
@onready var idle: Idle = $StateMachine/Idle
@onready var chasing: Chasing = $StateMachine/Chasing
@onready var jump: Jump = $StateMachine/Jump
@onready var attack: Attack = $StateMachine/Attack
@onready var shooting_states: LimboHSM = $StateMachine/ShootingStates
@onready var shooting: Shooting = $StateMachine/ShootingStates/Shooting
@onready var shooting_defense: LimboState = $StateMachine/ShootingStates/ShootingDefense
@onready var reload: LimboState = $StateMachine/ShootingStates/Reload
@onready var hit: Hit = $StateMachine/Hit
@onready var parry: Parry = $StateMachine/Parry
@onready var staggered: Staggered = $StateMachine/Staggered
@onready var dying: BTState = $StateMachine/Dying
@onready var death: Death = $StateMachine/Death



var state

#Combat States
@onready var combat_state_change_handler: CombatStateChangeHandler = $CombatStateChangeHandler
@onready var combat_state_machine: LimboHSM = $CombatStateMachine
@onready var ranged_mode: LimboState = $CombatStateMachine/ranged
@onready var melee_mode: LimboState = $CombatStateMachine/melee



#ATTACKS
@onready var melee_attack_manager: MeleeAttackManager = $MeleeAttackManager
@onready var attack_range: AttackRange = $AttackRange
@onready var hit_box: HitBox = $HitBox
@onready var hb_collision: CollisionShape2D = $HitBox/hb_collision
@onready var atk_chain : String = "_1"
@export var hitbox: HitBox
var parried : bool = false 
var attacking : bool = false


#Shooting
@onready var shoot_attack_manager: ShootAttackManager = $ShootAttackManager
@onready var shoot_handler: ShootHandler = $ShootHandler
@onready var bullet = BALL_PROCETILE
@onready var bullet_dir = Vector2.RIGHT
@onready var turret: Turret = $Turret
@onready var ammo_count

#DEATH
@export var drop = preload("res://heart.tscn")
@onready var death_handler: DeathHandler = $DeathHandler
@export var death_time_scale: float = 1.0
@onready var norm_delta

#Debug var
var combat_state : String = "RANGED"

	
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
	bt_player.blackboard.set_var("staggered", false)
	Events.enemy_parried.connect(parry_success)
	#turret.setup(0.2)
	turret.shoot_timer.paused=true
	_init_state_machine()
	_init_combat_state_machine()
	_init_shooting_states()
	hurt_box.set_damage_mulitplyer(1)
	player_tracking.target_position=Vector2(vision_handler.vision_range,0)

func _process(delta: float) -> void:
	knockback=clamp(knockback, Vector2(-400, -400), Vector2(400, 400) )
	knockback = lerp(knockback, Vector2.ZERO, 0.1)
	ammo_count=turret.ammo_count
	dir = to_local(next)
	vision_handler.handle_vision()
	distance = abs(global_position.x-player.global_position.x)
	defense_shoot()
	reload_gun()
	#print(distance)

func _physics_process(delta: float) -> void:
	if combat_state_machine.get_active_state()==ranged_mode or state_machine.get_active_state()==parry:
		current_speed=0
	
	velocity.x = current_speed + knockback.x
	move_and_slide()
	movement_handler.apply_gravity(delta)

func _init_state_machine():
	state_machine.initial_state=idle
	state_machine.initialize(self)
	state_machine.set_active(true)

	state_machine.add_transition(idle, attack, &"attack_mode")
	state_machine.add_transition(staggered, chasing, &"stagger_recover")
	state_machine.add_transition(attack, chasing, &"start_chase")
	state_machine.add_transition(shooting_states, chasing, &"start_chase")
	state_machine.add_transition(chasing, attack, &"start_attack")
	#state_machine.add_transition(shooting_states, attack, &"start_attack")
	state_machine.add_transition(attack, idle, &"idle_mode")
	state_machine.add_transition(chasing, jump, &"jump")
	state_machine.add_transition(jump, chasing, &"land")
	state_machine.add_transition(hit, attack, &"hit_recover")
	state_machine.add_transition(attack, parry, &"parry")
	state_machine.add_transition(chasing, parry, &"parry")
	state_machine.add_transition(shooting_states, parry, &"parry")
	state_machine.add_transition(parry, attack, parry.failure_event)
	state_machine.add_transition(parry, shooting_states, parry.success_event)
	state_machine.add_transition(attack, shooting_states, &"start_shoot")
	state_machine.add_transition(chasing, shooting_states, &"start_shoot")
	
	state_machine.add_transition(state_machine.ANYSTATE, hit, &"hit")
	state_machine.add_transition(state_machine.ANYSTATE, dying, &"die")
	state_machine.add_transition(dying, death, dying.success_event)
	state_machine.add_transition(state_machine.ANYSTATE, staggered, &"staggered")
	
func _init_combat_state_machine():
	combat_state_machine.initial_state=ranged_mode
	combat_state_machine.initialize(self)
	combat_state_machine.set_active(true)
	
	combat_state_machine.add_transition(ranged_mode, melee_mode, &"melee_mode")
	combat_state_machine.add_transition(melee_mode, ranged_mode, &"ranged_mode")

func _init_shooting_states():
	shooting_states.initial_state=shooting
	shooting_states.initialize(self)
	shooting_states.set_active(true)
	
	shooting_states.add_transition(shooting, shooting_defense, &"defensive_shoot")
	shooting_states.add_transition(shooting_defense, shooting, &"offensive_shoot")
	shooting_states.add_transition(shooting_states.ANYSTATE, reload, &"reload")
	shooting_states.add_transition(reload, shooting, &"return_shooting")
	
#Navigation
func makepath() -> void:
	nav_agent.target_position = player.global_position
func _on_navigation_timer_timeout() -> void:
	makepath()
	next_y=nav_agent.get_next_path_position().y
	next_x=nav_agent.get_next_path_position().x
	next=nav_agent.get_next_path_position()


	
func defense_shoot() -> void:
	#print(distance)
	if distance>=50:
		shooting_states.dispatch(&"offensive_shoot")
		#print("offensive")
	elif distance<50:
		shooting_states.dispatch(&"defensive_shoot")
		#print("defensive")

func reload_gun() -> void:
	if state_machine.get_active_state()==shooting_states:
		if turret.ammo_count<=0:
			shooting_states.dispatch(&"reload")

func target_lock():
	Events.unlock_from.emit()
	target_lock_node.target_lock()
	
func get_width() -> int:
	return abs(collision_shape_2d.get_shape().size.x * scale.x)
func get_height() -> int:
	return abs(collision_shape_2d.get_shape().size.y * scale.y)



func _on_state_machine_active_state_changed(current: LimboState, previous: LimboState) -> void:
	if current!=idle:
		movement_handler.active=true
	#match current:
		#attack:
			#if combat_state_machine.get_active_state()==ranged_mode:
				#state_machine.dispatch(&"start_shoot")
		#chasing:
			#if combat_state_machine.get_active_state()==ranged_mode:
				#state_machine.dispatch(&"start_shoot")
		#shooting:
			#if combat_state_machine.get_active_state()==melee_mode:
				#state_machine.dispatch(&"start_chase")


func _on_combat_state_machine_active_state_changed(current: LimboState, previous: LimboState) -> void:
	if state_machine.get_active_state()==idle:
		return
	
	if current==ranged_mode:
		state_machine.dispatch(&"start_shoot")
		movement_handler.active=false
		current_speed=0
	elif current==melee_mode:
		movement_handler.active=true
		state_machine.dispatch(&"start_chase")
		

func _on_chasing_entered() -> void:
	animation_player.play("run")
	chase_speed=40


func _on_shooting_entered() -> void:
	animation_player.play("shoot")


func _on_shooting_defense_entered() -> void:
	animation_player.play("shoot_defense")


func _on_attack_entered() -> void:
	if combat_state_machine.get_active_state()==ranged_mode:
		state_machine.dispatch(&"start_shoot")
	elif combat_state_machine.get_active_state()==melee_mode:
		state_machine.dispatch(&"start_chase")


func being_flipped() -> void:
	if player_state==player.States.FLIP:
		movement_handler.face_player_active=false
	else:
		movement_handler.face_player_active=true

func _on_shooting_states_active_state_changed(current: LimboState, previous: LimboState) -> void:
	pass
	#print("change shoot stance")


func _on_attack_range_body_entered(body: Node2D) -> void:
	state_machine.dispatch(&"parry")

func parry_success() -> void:
	print("parried")
	gpu_particles_2d.emitting=true
	gpu_particles_2d_2.emitting=true
	parry.blackboard.set_var("parry_success" , true)


func _on_parry_exited() -> void:
	print("parry exit")


func _on_turret_shoot_bullet() -> void:
	shoot_handler.shoot_bullet()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="reload":
		shooting_states.dispatch(&"return_shooting")


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if state_machine.get_active_state()==parry and player_state!=player.States.FLIP:
		return
	if area.is_in_group("sp_atk_default"):
		if player.state==player.States.FLIP or player.prev_state==player.States.FLIP:
			Events.allied_enemy_hit.emit()
		print("spc_hit")
		if animated_sprite_2d.flip_h:
			knockback.x=50
		else:
			knockback.x=-50
		stagger.stagger -= player.sp_atk_dmg

		
func _on_hurt_box_weakpoint_weakpoint_hit() -> void:
	if state_machine.get_active_state()==parry and player_state!=player.States.FLIP:
		return
	else:
		if player.state==player.States.FLIP or player.prev_state==player.States.FLIP:
			Events.allied_enemy_hit.emit()
		print("spc_hit")
		if animated_sprite_2d.flip_h:
			knockback.x=50
		else:
			knockback.x=-50
		stagger.stagger -= player.sp_atk_dmg*3



func _on_stagger_staggered() -> void:
	stagger_timer.start(3)
	hb_collision.disabled=true
	current_speed=0
	state_machine.dispatch(&"staggered")


func _on_hurt_box_received_damage(damage: int) -> void:
	if player.state==player.States.FLIP or player.prev_state==player.States.FLIP:
		Events.allied_enemy_hit.emit()
	
	#bt_player.restart()
	if state_machine.get_active_state()==death:
		return
	health.set_temporary_immortality(0.2)
	if damage<=health.health:
		parry_timer.start(0.5)
		state_machine.dispatch(&"hit")
		hit_stop.hit_stop(0.05,0.25)
		#set_state(current_state, States.HIT)
		gpu_particles_2d.emitting=true
		
	else:
		print("kill shot")


func _on_stagger_timer_timeout() -> void:
	state_machine.dispatch(&"stagger_recover")


func _on_parry_timer_timeout() -> void:
	state_machine.dispatch(&"hit_recover")
	


func _on_health_health_depleted() -> void:
	parry_timer.stop()
	hb_collision.disabled=true
	movement_handler.active=false
	animated_sprite_2d.scale.x = 1
	movement_handler.active=false
	knockback.x=250
	jump_handler.handle_jump(0.2)
	death_handler.death()
