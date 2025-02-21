class_name SoldierEnemy
extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const BALL_PROCETILE = preload("res://Component/ball_procetile.tscn")


@onready var wall_check_left = $WallChecks/WallCheckLeft as RayCast2D
@onready var wall_check_right = $WallChecks/WallCheckRight as RayCast2D
@onready var floor_checks_left = $FloorChecks/FloorChecksLeft as RayCast2D
@onready var floor_checks_right = $FloorChecks/FloorChecksRight as RayCast2D
@onready var player_tracking = $PlayerTrackerPivot/PlayerTracking as RayCast2D
@onready var player_tracker_pivot = $PlayerTrackerPivot as Node2D
@onready var chase_timer = $ChaseTimer as Timer
@onready var animated_sprite_2d = $AnimatedSprite2D as AnimatedSprite2D
@onready var animation_player = $AnimationPlayer as AnimationPlayer
@onready var nav_agent = $NavigationAgent2D
@onready var jump_timer = $JumpTimer

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
@onready var shooting_cooldown = $ShootingCooldown

@onready var health = $Health
@onready var hurt_box = $HurtBox
@onready var hb_collison = $HitBox/CollisionShape2D
@onready var h_bar = $HBar
@onready var parry_timer = $ParryTimer as Timer
var immortal = false
@onready var stagger = $Stagger
@onready var hurt_box_weak_point = $AnimatedSprite2D/HurtBox_WeakPoint

@onready var collision_shape_2d = $CollisionShape2D

@onready var bt_player = $BTPlayer

@export var jump_speed : float = 120.0
@export var hitbox: HitBox

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
var state
var distance


enum States{
	GUARD,
	CHASE,
	JUMP,
	ATTACK,
	PARRY,
	DEATH,
	SHOOTING,
	STAGGERED,
	DODGE
}

var current_state = States.GUARD
var prev_state = States.GUARD

enum CombatStates{
	RANGED,
	MELEE,
	}
	
var current_combat_state = CombatStates.RANGED
var prev_combat_state = CombatStates.RANGED
var combat_state : String = "RANGED"
	
func _ready():
	player = get_tree().get_first_node_in_group("player")
	#set_state(current_state, States.CHASE)
	animation_player.play("guard")
	state="guard"
	next_y=nav_agent.get_next_path_position().y
	bt_player.blackboard.set_var("attack_mode", false)
	bt_player.blackboard.set_var("melee_mode", false)
	bt_player.blackboard.set_var("ranged_mode", false)
	turret.setup(2)
	turret.shoot_timer.paused=true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _process(_delta):
	health_bar()
	track_player()
	combat_state_change()
	handle_vision()
	

func _physics_process(delta):
	move_and_slide()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	

func handle_vision():
	if player_tracking.is_colliding():
		var collision_result = player_tracking.get_collider()
		
		if collision_result != player:
			return
		else:
			set_state(current_state, States.ATTACK)
			#chase_timer.start(1)
			player_found = true
			
	else:
		player_found = false
	#player_found=true

func track_player():
	
	var direction_to_player : Vector2 = Vector2(player.position.x, player.position.y)\
	- player_tracking.position
	
	player_tracker_pivot.look_at(direction_to_player)
	
func combat_state_change():
	distance=abs(global_position.x-player.global_position.x)
	if distance>100:
		bt_player.blackboard.set_var("ranged_mode", true)
		bt_player.blackboard.set_var("melee_mode", false)
		set_combat_state(current_combat_state, CombatStates.RANGED)
	else:
		bt_player.blackboard.set_var("melee_mode", true)
		bt_player.blackboard.set_var("ranged_mode", false)
		set_combat_state(current_combat_state, CombatStates.MELEE)

func shoot():
	animation_player.play("shoot")

func melee_attack():
	print("melee attack")
	animation_player.play("atk_1")

func health_bar():
	h_bar.text=str(health.health, " State: ", state, " : ", "Combat: ", combat_state)

func makepath() -> void:
	nav_agent.target_position = player.global_position

func set_state(cur_state, new_state) -> void:

	if(cur_state == new_state):
		return
	elif(cur_state==States.DEATH):
		return
	elif(cur_state==States.STAGGERED and not parry_timer.is_stopped()):
		return
	
	else:
		current_state = new_state
		prev_state = cur_state
		#print(current_state, " : ", prev_state)
		match current_state:
			States.ATTACK:
				state="ATTACK"
				bt_player.blackboard.set_var("attack_mode", true)
				attacking=true
				#gravity=0
			States.GUARD:
				state="GUARD"
				hb_collison.disabled=false
				#print(str(prev_speed," ",current_speed))
				animation_player.speed_scale = 1
				animation_player.play("idle")
			States.CHASE:
				player_found=true
				hb_collison.disabled=false
				state="CHASE"
				animation_player.speed_scale =2
				if prev_state==States.JUMP:
					current_speed=prev_speed
			States.JUMP:
				prev_speed=current_speed
				#print("jumping")
				state="JUMP"
				if current_speed < 0:
					current_speed = -jump_speed
				else:
					current_speed = jump_speed
			States.PARRY:
				hb_collison.disabled=true
			States.DEATH:
				state="DEATH"
				hb_collison.disabled=false
			States.SHOOTING:
				state="shooting"
			States.STAGGERED:
				state="staggered"
				animation_player.play("Staggered")
				hb_collison.disabled=false
			States.DODGE:
				state="Dodging"
				
func set_combat_state(cur_state, new_state) -> void:

	if(cur_state == new_state):
		return
	elif(current_state==States.DEATH):
		return
	elif(current_state==States.STAGGERED and not parry_timer.is_stopped()):
		return
	
	else:
		current_combat_state = new_state
		prev_combat_state = cur_state
		if current_state==States.ATTACK:
			match current_combat_state:
				CombatStates.RANGED:
					combat_state="Ranged"
					#animation_player.play("shoot")
				CombatStates.MELEE:
					print("melee range")
					combat_state="Melee"
					#animation_player.play("atk_1")
		else:
			pass



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass # Replace with function body.
