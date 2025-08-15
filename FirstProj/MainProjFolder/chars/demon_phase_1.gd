extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -400.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#Basic
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var npc_stats: Control = $NPCStats

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

@onready var left_explosion: GPUParticles2D = $AnimatedSprite2D/LeftExplosion
@onready var left_sparks: GPUParticles2D = $AnimatedSprite2D/LeftExplosion/GPUParticles2D
@onready var right_explosion: GPUParticles2D = $AnimatedSprite2D/RightExplosion
@onready var right_sparks: GPUParticles2D = $AnimatedSprite2D/RightExplosion/GPUParticles2D

#Cutscene Handler
@onready var cutscene_handler: CutsceneHandler = $CutsceneHandler
signal death_cutscene
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
@export var keep_dis_speed : float = 40.0

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
var player_found : bool = false
var player : PlayerEntity = null
var distance
var player_state : LimboState

#States
@onready var state_machine: LimboHSM = $LimboHSM
@onready var idle: LimboState = $LimboHSM/IDLE
@onready var chasing: LimboState = $LimboHSM/CHASING
@onready var jump: LimboState = $LimboHSM/JUMP
@onready var death: LimboState = $LimboHSM/DEATH
@onready var dying: BTState = $LimboHSM/DYING
@onready var attack: LimboState = $LimboHSM/ATTACK
@onready var charge: BTState = $LimboHSM/CHARGE
@onready var teleport: BTState = $LimboHSM/TELEPORT
@onready var slam: BTState = $LimboHSM/SLAM

@onready var dodge: LimboState = $LimboHSM/DODGE
@onready var hit: LimboState = $LimboHSM/HIT
@onready var staggered: LimboState = $LimboHSM/STAGGERED
var state

#Combat States
@onready var combat_state_change_handler: CombatStateChangeHandler = $CombatStateChangeHandler
@onready var combat_state_machine: LimboHSM = $CombatStateMachine
@onready var ranged_mode: ranged = $CombatStateMachine/ranged
@onready var melee_mode: melee = $CombatStateMachine/melee


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
@onready var ammo_count = 0

#DEATH
@export var drop = preload("res://heart.tscn")
@onready var death_handler: DeathHandler = $DeathHandler
@export var death_time_scale: float = 1.0
@onready var norm_delta

#LVL Boss flag
@export var lvl_boss : bool = false

#Debug var
var combat_state : String = "RANGED"
@onready var debuging: Label = $DEBUGING

func _ready() -> void:
	_init_state_machine()



func _init_state_machine():
	state_machine.initial_state=idle
	state_machine.initialize(self)
	state_machine.set_active(true)

	state_machine.add_transition(idle, attack, &"attack_mode")
	state_machine.add_transition(staggered, chasing, &"stagger_recover")
	state_machine.add_transition(attack, chasing, &"start_chase")
	state_machine.add_transition(idle, chasing, &"start_chase")
	state_machine.add_transition(chasing, attack, &"start_attack")

	
	state_machine.add_transition(attack, idle, &"idle_mode")
	state_machine.add_transition(attack, jump, &"jump_attack")
	state_machine.add_transition(chasing, jump, &"jump")
	state_machine.add_transition(jump, chasing, &"land")
	state_machine.add_transition(jump, attack, &"land_attack")
	state_machine.add_transition(hit, attack, &"hit_recover")
	state_machine.add_transition(attack, dodge, &"dodge")
	state_machine.add_transition(dodge, attack, &"dodge_end")
	
	state_machine.add_transition(chasing, charge, &"charge_attack")
	state_machine.add_transition(chasing, teleport, &"teleport")
	state_machine.add_transition(charge, attack, &"heavy_attack")
	state_machine.add_transition(charge, teleport, &"teleport_counter")
	state_machine.add_transition(teleport, slam, &"slam_attack")

	
	state_machine.add_transition(state_machine.ANYSTATE, hit, &"hit")
	state_machine.add_transition(state_machine.ANYSTATE, dying, &"die")
	state_machine.add_transition(dying, death, dying.success_event)
	state_machine.add_transition(state_machine.ANYSTATE, staggered, &"staggered")




func _process(delta: float) -> void:
	if not cutscene_handler.actor_control_active: 
		vision_handler.handle_vision()
		return
		

func _physics_process(delta: float) -> void:
	if not cutscene_handler.actor_control_active:
		apply_gravity(delta)
		current_speed=0
		move_and_slide()
		return
		
func apply_gravity(delta : float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func makepath() -> void:
	nav_agent.target_position = player.global_position
	
func target_lock():
	Events.unlock_from.emit()
	target_lock_node.target_lock()
	
func chase():
	#set_state(current_state, States.CHASE)
	state_machine.dispatch(&"start_chase")
	
func get_width() -> int:
	return abs(collision_shape_2d.get_shape().radius * scale.x)
func get_height() -> int:
	return abs(collision_shape_2d.get_shape().height * scale.y)

func teleport_to() -> void:
	global_position=player.global_position 

func _on_navigation_timer_timeout() -> void:
	makepath()



func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and state_machine.get_active_state()!=staggered:
		pass # Replace with function body.



func _on_limbo_hsm_active_state_changed(current: LimboState, previous: LimboState) -> void:
	pass # Replace with function body.



func _on_health_health_depleted() -> void:
	pass # Replace with function body.



func _on_hurt_box_received_damage(damage: int) -> void:
	pass # Replace with function body.



func _on_parry_timer_timeout() -> void:
	pass # Replace with function body.


func _on_animation_player_animation_started(anim_name: StringName) -> void:
	pass # Replace with function body.


func _on_stagger_staggered() -> void:
	pass # Replace with function body.
