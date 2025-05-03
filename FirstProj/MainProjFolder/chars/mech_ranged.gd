class_name mech_enemy
extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -400.0
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
#On Screen

#Defense
@onready var health: Health = $Health
@onready var stagger: Stagger = $Stagger
@onready var hurt_box: HurtBox = $HurtBox
@onready var hurt_box_collision: CollisionShape2D = $HurtBox/hurt_box_collision
@onready var hit_stop: HitStop = $HitStop
@onready var hit_stop_dur = 0.0

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
@export var chase_speed : float = 80.0

var current_speed : float = 40.0
var prev_speed : float = 40.0
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
@onready var state_machine: LimboHSM = $LimboHSM
@onready var idle: LimboState = $LimboHSM/IDLE
@onready var chasing: LimboState = $LimboHSM/CHASING
@onready var jump: LimboState = $LimboHSM/JUMP
@onready var death: LimboState = $LimboHSM/DEATH
@onready var dying: BTState = $LimboHSM/DYING
@onready var attack: LimboState = $LimboHSM/ATTACK
@onready var shooting: LimboState = $LimboHSM/SHOOTING
@onready var slam: BTState = $LimboHSM/SLAM

@onready var dodge: LimboState = $LimboHSM/DODGE
@onready var hit: LimboState = $LimboHSM/HIT
@onready var staggered: LimboState = $LimboHSM/STAGGERED
var state

#Combat States
@onready var combat_state_change_handler: CombatStateChangeHandler = $CombatStateChangeHandler
@onready var combat_state_machine: LimboHSM = $CombatStateMachine
@onready var ranged: LimboState = $CombatStateMachine/RANGED
@onready var melee: LimboState = $CombatStateMachine/MELEE



#ATTACKS
@onready var melee_attack_manager: MeleeAttackManager = $MeleeAttackManager
@onready var dodge_manager: DodgeManager = $DodgeManager
@onready var attack_range: AttackRange = $AttackRange
@onready var ar_box: CollisionShape2D = $AttackRange/CollisionShape2D
@onready var hit_box: HitBox = $HitBox
@onready var hb_collision: CollisionShape2D = $HitBox/hb_collision
@onready var atk_chain : String = "_1"
@export var hitbox: HitBox
var parried : bool = false 
var attacking : bool = false
var slam_vel : float = 0.0

#Shooting
@onready var shoot_attack_manager: ShootAttackManager = $ShootAttackManager
@onready var shoot_handler: ShootHandler = $ShootHandler
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
@onready var debuging: Label = $DEBUGING

func _ready():
	player = get_tree().get_first_node_in_group("player")
	#set_state(current_state, States.CHASE)
	_init_state_machine()
	animation_player.play("idle")
	state="guard"
	next=nav_agent.get_next_path_position()
	#bt_player.blackboard.set_var("attack_mode", false)
	#bt_player.blackboard.set_var("melee_mode", false)
	bt_player.blackboard.set_var("within_range", false)
	bt_player.blackboard.set_var("staggered", false)
	dying.blackboard.set_var("hit_the_floor", false)
	turret.shoot_timer.paused=true
	hurt_box.set_damage_mulitplyer(1)
	ammo_count=turret.ammo_count
	
	###########################
	#Debug inits to be removed#
	###########################
	bt_player.blackboard.set_var("attack_mode", true)
	bt_player.blackboard.set_var("melee_mode", true)
	shoot_handler.set_projectile(Projectiles.BALL_PROCETILE)
	
func _init_state_machine():
	state_machine.initial_state=idle
	state_machine.initialize(self)
	state_machine.set_active(true)

	state_machine.add_transition(idle, attack, &"attack_mode")
	state_machine.add_transition(staggered, chasing, &"stagger_recover")
	state_machine.add_transition(attack, chasing, &"start_chase")
	state_machine.add_transition(idle, chasing, &"start_chase")
	state_machine.add_transition(chasing, attack, &"start_attack")
	state_machine.add_transition(jump, slam, &"slam_attack")
	state_machine.add_transition(attack, idle, &"idle_mode")
	state_machine.add_transition(attack, jump, &"jump_attack")
	state_machine.add_transition(chasing, jump, &"jump")
	state_machine.add_transition(jump, chasing, &"land")
	state_machine.add_transition(jump, attack, &"land_attack")
	state_machine.add_transition(hit, attack, &"hit_recover")
	state_machine.add_transition(attack, dodge, &"dodge")
	state_machine.add_transition(dodge, attack, &"dodge_end")
	state_machine.add_transition(slam, attack, slam.success_event)
	state_machine.add_transition(slam, hit, slam.failure_event)
	
	
	state_machine.add_transition(state_machine.ANYSTATE, hit, &"hit")
	state_machine.add_transition(state_machine.ANYSTATE, dying, &"die")
	state_machine.add_transition(dying, death, dying.success_event)
	state_machine.add_transition(state_machine.ANYSTATE, staggered, &"staggered")
	
func _process(delta: float) -> void:
	ammo_count=turret.ammo_count
	dir = to_local(next)
	debuging.text=str(global_position.x)
	#print(velocity.y)
	if state_machine.get_active_state()==death or state_machine.get_active_state()==staggered or state_machine.get_active_state()==hit:
		hb_collision.disabled=true
		return
	elif state_machine.get_active_state()==idle:
		hb_collision.disabled=true

	vision_handler.handle_vision()
	if not attack_range.has_overlapping_bodies():
		bt_player.blackboard.set_var("within_range", false)
	#bt_player.blackboard.get_var("attack_mode"))
	attack_timer.one_shot=true
	
func _physics_process(delta: float) -> void:
	knockback = lerp(knockback, Vector2.ZERO, 0.1)
#	stop movement when hit, staggered, or dead
	if  state_machine.get_active_state()==hit or state_machine.get_active_state()==staggered:
		#hb_collison.disabled=true
		velocity.y += gravity * delta
		velocity.x=0
		move_and_slide()
		return
	elif state_machine.get_active_state()==jump:
		global_position.x=lerpf(global_position.x, player.global_position.x, 0.6*delta)
	elif state_machine.get_active_state()==slam:
		#print("slamming")
		velocity.y += slam_vel * delta
		move_and_slide()
	elif state_machine.get_active_state()==dying:
		move_and_slide()
		if is_on_floor() and not jump_timer.is_stopped():
			dying.blackboard.set_var("hit_the_floor", true)
		else:
			
			if death_timer.is_stopped():
				delta=delta
				velocity.y += gravity * delta
				animation_player.speed_scale=1
			else:
				delta*=lerpf(death_time_scale, 0, 0.2)
				animation_player.speed_scale=.5
				velocity.y += gravity * delta
				velocity.y=lerpf(velocity.y,0,0.2)
		velocity.x=knockback.x
	elif state_machine.get_active_state()==death :
		hb_collision.disabled=true
		return
	

	
	if state_machine.get_active_state()==staggered and parry_timer.time_left>0.0:
		state_machine.change_active_state(staggered)
		
	#handle_movement()
	if state_machine.get_active_state()==chasing:
		velocity.x = current_speed + knockback.x
		velocity.y += gravity * delta
	else:
		velocity.x= knockback.x
		
	#	apply gravity when in air
	if not is_on_floor() and state_machine.get_active_state()!=slam:
		velocity.y += gravity * delta
	move_and_slide()

func makepath() -> void:
	nav_agent.target_position = player.global_position
	
		
func target_lock():
	Events.unlock_from.emit()
	target_lock_node.target_lock()
	
func chase():
	#set_state(current_state, States.CHASE)
	state_machine.dispatch(&"start_chase")
	
func get_width() -> int:
	return abs(collision_shape_2d.get_shape().size.x * scale.x)
func get_height() -> int:
	return abs(collision_shape_2d.get_shape().size.y * scale.y)

func jump_up() -> void:
	state_machine.dispatch(&"jump_attack")
	
func slam_down() -> void:
	state_machine.dispatch(&"slam_attack")

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	vision_handler.always_on=true



func _on_slam_exited() -> void:
	slam_vel=0


func _on_navigation_timer_timeout() -> void:
	makepath()


func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and state_machine.get_active_state()!=staggered:
		bt_player.blackboard.set_var("within_range", true)
		state_machine.dispatch(&"start_attack")


func _on_attack_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and state_machine.get_active_state()!=staggered and state_machine.get_active_state()!=slam:
		bt_player.blackboard.set_var("within_range", false)
		state_machine.dispatch(&"start_chase")
