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
@onready var player_right : bool = false

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
@onready var hit_box: HitBox = $HitBox

@onready var h_bar = $HBar
@onready var parry_timer = $ParryTimer as Timer
var immortal = false
@onready var stagger = $Stagger
@onready var hurt_box_weak_point = $AnimatedSprite2D/HurtBox_WeakPoint
@onready var attack_timer: Timer = $AttackTimer

@onready var collision_shape_2d = $CollisionShape2D

@onready var bt_player = $BTPlayer

@export var jump_speed : float = 120.0
@export var chase_speed : float = 80.0
@export var hitbox: HitBox
@onready var target_lock_node: Node2D = $TargetLock
@onready var attack_range: AttackRange = $AttackRange



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

@onready var atk_chain : String = "_1"

enum States{
	GUARD,
	CHASE,
	JUMP,
	ATTACK,
	PARRY,
	DEATH,
	SHOOTING,
	STAGGERED,
	DODGE,
	DEAD
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
var player_state : int
	
func _ready():
	player = get_tree().get_first_node_in_group("player")
	#set_state(current_state, States.CHASE)
	animation_player.play("guard")
	state="guard"
	next_y=nav_agent.get_next_path_position().y
	bt_player.blackboard.set_var("attack_mode", false)
	bt_player.blackboard.set_var("melee_mode", false)
	bt_player.blackboard.set_var("ranged_mode", true)
	bt_player.blackboard.set_var("within_range", false)
	turret.setup(0.2)
	turret.shoot_timer.paused=true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _process(_delta):
	if current_state==States.DEATH or current_state==States.STAGGERED:
		#print("returning")
		return
	health_bar()
	track_player()
	combat_state_change()
	handle_vision()
	#print(bt_player.blackboard.get_var("attack_mode"))
	attack_timer.one_shot=true
	get_player_state(player)
	#print(current_combat_state," ",prev_combat_state)

func _physics_process(delta):
	if current_state==States.DEATH or current_state==States.STAGGERED:
		#print("returning")
		return
	move_and_slide()
	counter_attack()
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	handle_movement()
	if current_state==States.CHASE:
		velocity.x = current_speed + knockback.x
	else:
		velocity.x= knockback.x
	
	knockback = lerp(knockback, Vector2.ZERO, 0.1)
	
	
func handle_vision():
	if player_tracking.is_colliding():
		var collision_result = player_tracking.get_collider()
		
		if collision_result != player:
			set_state(current_state, States.GUARD)
			return
		else:
			set_state(current_state, States.ATTACK)
			#chase_timer.start(1)
			player_found = true
			
	else:
		
		set_state(current_state, States.GUARD)
		player_found = false
		
	if not attack_range.has_overlapping_bodies():
		bt_player.blackboard.set_var("within_range", false)
		
	if current_combat_state==CombatStates.RANGED and player_found:
		set_state(current_state, States.ATTACK)
	elif current_combat_state==CombatStates.MELEE:
		if bt_player.blackboard.get_var("within_range"):
			set_state(current_state, States.ATTACK)
		else:
			set_state(current_state, States.CHASE)
			#chase_timer.start(1)
	#player_found = true
	
	
	
func track_player():
	
	var direction_to_player : Vector2 = Vector2(player.position.x, player.position.y)\
	- player_tracking.position
	
	player_tracker_pivot.look_at(direction_to_player)
	
func handle_movement() -> void:
	
	var direction= global_position - player.global_position
	
	
	if player_found == true:
		
		var dir = to_local(nav_agent.get_next_path_position())
		#print(dir)
		if dir.x > 0 and is_on_floor():
			current_speed = chase_speed
			animated_sprite_2d.scale.x = -1
			hit_box.scale.x = -1
		else:
			current_speed = -chase_speed
			animated_sprite_2d.scale.x = 1
			hit_box.scale.x = 1
			

func combat_state_change():
	distance=abs(global_position.x-player.global_position.x)
	if distance>100:
		turret.shoot_timer.paused=false
		set_combat_state(current_combat_state, CombatStates.RANGED)
		
	else:
		turret.shoot_timer.paused=true
		set_combat_state(current_combat_state, CombatStates.MELEE)
func target_lock():
	Events.unlock_from.emit()
	target_lock_node.target_lock()
	

func chase():
	set_state(current_state, States.CHASE)
	
func handle_jump():
	if jump_timer.is_stopped():
		velocity.y = jump_velocity
		set_state(current_state, States.JUMP)
		jump_timer.start(2)
	

func shoot():
	animation_player.play("shoot")
	turret.shoot()
	

func melee_attack():
	set_state(current_state,States.ATTACK)
	#print("melee attack")
	animation_player.play("atk"+atk_chain)

func health_bar():
	h_bar.text=str(health.health, " : ", stagger.stagger, " : State:", combat_state, " DIST. ", distance)

func makepath() -> void:
	nav_agent.target_position = player.global_position

func set_state(cur_state, new_state) -> void:

	if(cur_state == new_state):
		return
	elif(cur_state==States.DEATH):
		return
	elif(cur_state==States.STAGGERED and not parry_timer.is_stopped()) and not (new_state==States.DEATH):
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
				bt_player.blackboard.set_var("attack_mode", false)
				animation_player.speed_scale = 1
				animation_player.play("idle")
			States.CHASE:
				player_found=true
				hb_collison.disabled=false
				state="CHASE"
				bt_player.blackboard.set_var("attack_mode", true)
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
				hb_collison.disabled=true
				state="DEATH"
				bt_player.blackboard.set_var("attack_mode", false)
			States.SHOOTING:
				state="shooting"
			States.STAGGERED:
				state="staggered"
				animation_player.play("Staggered")
				hb_collison.disabled=false
				bt_player.blackboard.set_var("attack_mode", false)
			States.DODGE:
				state="Dodging"
				
func set_combat_state(cur_state, new_state) -> void:
	#print(cur_state, " ", new_state)
	if(cur_state == new_state):
		return
		print("no change")
	elif(current_state==States.DEATH):
		return
	elif(current_state==States.STAGGERED):
		return
	
	else:
		current_combat_state = new_state
		prev_combat_state = cur_state
		
		match current_combat_state:
			CombatStates.RANGED:
				combat_state="Ranged"
				bt_player.blackboard.set_var("ranged_mode", true)
				bt_player.blackboard.set_var("melee_mode", false)
				
				#animation_player.play("shoot")
			CombatStates.MELEE:
				print("melee range")
				bt_player.blackboard.set_var("melee_mode", true)
				bt_player.blackboard.set_var("ranged_mode", false)
				combat_state="Melee"
					
					
					#animation_player.play("atk_1")
		
func get_player_state(player: PlayerEntity) -> void:
	player_state=player.get_state_enum()
	
func counter_attack():
	if player_state == player.States.SPECIAL_ATTACK:
		#print("jump")
		handle_jump()

func get_width() -> int:
	return collision_shape_2d.get_shape().radius
func get_height() -> int:
	return collision_shape_2d.get_shape().radius

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"atk_1":
			atk_chain="_2"
			attack_timer.start(5)
		"atk_2":
			atk_chain="_3"
			attack_timer.start(5)
		"atk_3":
			atk_chain="_1"
			attack_timer.start(5)
			


func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("in range")
		bt_player.blackboard.set_var("within_range", true)
		set_state(current_state, States.ATTACK)

func _on_attack_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and not animation_player.is_playing():
		print("out of range")
		bt_player.blackboard.set_var("within_range", false)
		set_state(current_state, States.CHASE)
		
func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("sp_atk_default"):
		print("spc_hit")
		if animated_sprite_2d.flip_h:
			knockback.x=50
		else:
			knockback.x=-50
		stagger.stagger -= player.sp_atk_dmg

func _on_navigation_timer_timeout() -> void:
	makepath()
	next_y=nav_agent.get_next_path_position().y


func _on_stagger_staggered() -> void:
	set_state(current_state, States.STAGGERED)
	parry_timer.start(5)
	hurt_box.set_damage_mulitplyer(3)
	print("staggered")
	hb_collison.disabled


func _on_parry_timer_timeout() -> void:
	set_state(current_state, prev_state)
	hurt_box.set_damage_mulitplyer(1)


func _on_hit_box_parried() -> void:
	pass # Replace with function body.


func _on_health_health_depleted() -> void:
	print("dying")
	set_state(current_state, States.DEATH)
	hb_collison.disabled=false
	animation_player.play("death")
	await animation_player.animation_finished
	animation_player.play("dead")

func _on_attack_timer_timeout() -> void:
	#print("begin move")
	if bt_player.blackboard.get_var("within_range"):
		set_state(current_state, States.ATTACK)
	else:
		set_state(current_state, States.CHASE)


func _on_turret_shoot_bullet() -> void:
	var bullet_inst = bullet.instantiate()
	bullet_inst.set_speed(400.0)
	#bullet_inst.set_accel(50.0)
	#bullet_inst.tracking_time=0.01
	bullet_inst.dir = (turret.player_tracker.target_position).normalized()
	bullet_inst.spawnPos = Vector2(position.x, position.y)
	bullet_inst.spawnRot = player_tracker_pivot.rotation_degrees
	#print(bullet_inst.dir)
	
	get_tree().current_scene.add_child(bullet_inst)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if current_state==States.DEATH:
		queue_free()
