class_name RobotEnemy
extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

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
@onready var next_y : float = 0
@onready var navigation_timer = $NavigationTimer

@export var drop = preload("res://heart.tscn")
@onready var death_timer = $DeathTimer
@export var explode = preload("res://Component/explosion.tscn")

@onready var floor_jump_check_right = $JumpChecks/FloorJumpCheckRight as RayCast2D
@onready var floor_jump_check_left = $JumpChecks/FloorJumpCheckLeft as RayCast2D
@onready var gap_check_left = $JumpChecks/GapCheckLeft as RayCast2D
@onready var gap_check_right = $JumpChecks/GapCheckRight as RayCast2D
@onready var leap_up_check_left = $JumpChecks/LeapUpCheckLeft
@onready var leap_up_check_right = $JumpChecks/LeapUpCheckRight
@onready var jump_timer = $JumpTimer


@onready var health = $Health
@onready var hurt_box = $HurtBox
@onready var hb_collison = $HitBox/CollisionShape2D
@onready var h_bar = $HBar
@onready var parry_timer = $ParryTimer as Timer
var immortal = false


@export var wander_speed : float = 40.0
@export var chase_speed : float = 80.0
@export var jump_speed : float = 120.0
@export var hitbox: HitBox

var current_speed : float = 40.0
var prev_speed : float = 40.0
var acceleration : float = 800.0
var player_found : bool = false
var player : PlayerEntity = null
var jump_velocity = JUMP_VELOCITY
var knockback : Vector2 = Vector2.ZERO
var parried : bool = false 
var attacking : bool = false


enum States{
	WANDER,
	CHASE,
	JUMP,
	ATTACK,
	PARRY,
	DEATH
}

var current_state = States.CHASE
var prev_state = States.CHASE


func _ready():
	#chase_timer.timeout.connect(on_timer_timeout)
	player = get_tree().get_first_node_in_group("player")
	#set_state(current_state, States.WANDER)
	animation_player.play("walking")
	next_y=nav_agent.get_next_path_position().y
	player_found=true


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _process(_delta):
	#health_bar()
	#if current_state != States.PARRY:
		#hb_collison.disabled=false
	#
	handle_vision()
	track_player()
	#match current_state:
		#States.WANDER:
			#set_state(current_state, States.WANDER)
		#States.ATTACK:
			#set_state(current_state, States.ATTACK)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if not jump_timer.is_stopped():
		current_state=States.JUMP
	elif jump_timer.is_stopped() and is_on_floor() and current_state==States.JUMP:
		set_state(current_state,prev_state)
	#print(current_state, " , ", jump_timer.is_stopped(), " , ", is_on_floor())
	#print(navigation_timer.time_left)
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction = Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
	if parried==false:
		move_and_slide()
		hb_collison.disabled=false
	
	
	if knockback == Vector2.ZERO:
		handle_movement()
		if current_state!=States.JUMP:
			handle_jump()
		
	#if is_on_floor() and current_state==States.JUMP:
		##print("landed")
		#set_state(current_state,States.CHASE)
	
	#if parry_timer.is_stopped() :
		#current_state=prev_state
		#knockback = Vector2.ZERO
		#parried=false
	
	#print(state, ": ", current_state, prev_state)	
	#print(current_speed)
	#print(is_on_floor())
	#if current_state==States.JUMP:
		#print("in air")
	handl_animation()

	velocity.x = current_speed + knockback.x
	if current_state==States.DEATH:
		velocity.y = knockback.y
	
	if parried == true:
		hb_collison.disabled=true
	
	
		
	knockback = lerp(knockback, Vector2.ZERO, 0.1)
	
	
func handle_movement() -> void:
	var direction= global_position - player.global_position
	
	if current_speed == States.ATTACK:
		current_speed = 0

	
	if current_state == States.WANDER:
		#if is_on_floor() and current_speed==jump_speed:
			#current_speed = prev_speed
		if not floor_checks_right.is_colliding() and not wall_check_right.is_colliding():
			if gap_check_right.is_colliding():
				
				set_state(current_state, States.JUMP)
				#current_state=States.JUMP
			else:
				if is_on_floor():
					current_speed = -wander_speed
		if not floor_checks_left.is_colliding() and not wall_check_left.is_colliding():
			if gap_check_left.is_colliding():
				#velocity.y = jump_velocity
				set_state(current_state, States.JUMP)
				#current_state=States.JUMP
			else:
				if is_on_floor():
					current_speed = wander_speed
					
					
		if wall_check_right.is_colliding() and is_on_floor():
			current_speed = -wander_speed
		if wall_check_left.is_colliding() and is_on_floor():
			current_speed = wander_speed
	
	elif current_state == States.CHASE:
		if player_found == true:
			var dir = to_local(nav_agent.get_next_path_position())
			#print("moving to player")
			#if next_y<position.y:
				#if (not floor_checks_right.is_colliding()) and (floor_jump_check_right.is_colliding()) and is_on_floor(): 
					#velocity.y = jump_velocity
					#
					##current_state=States.JUMP
					#
				#if (not floor_checks_left.is_colliding()) and (floor_jump_check_left.is_colliding()) and is_on_floor():
					#velocity.y = jump_velocity
					
				#current_state=States.JUMP
			
			#if ( (leap_up_check_right.is_colliding() and current_speed>0 ) or (leap_up_check_left.is_colliding() and current_speed<0 ) ) and position.y-30>next_y:
				##print("jump")
				#velocity.y = jump_velocity*1.2
			#velocity = dir * SPEED
			#velocity.x = dir.x * chase_speed
			#print(dir.x)
			#print(is_on_floor())
			if dir.x > 0 and is_on_floor():
				current_speed = chase_speed
			else:
				current_speed = -chase_speed
	#
	if current_state == States.JUMP:
		
		#velocity.x = velocity.x
		if is_on_floor() and jump_timer.is_stopped():
			#print("landed")
			set_state(current_state, States.CHASE)
			current_speed=prev_speed
		#velocity.y = jump_velocity
		#current_speed=0.0
		#prev_state=States.JUMP
		
	velocity.x = current_speed

func handle_jump():
	if (leap_up_check_left.has_overlapping_bodies() or leap_up_check_right.has_overlapping_bodies()) and is_on_floor():
		#print("jump check")
		#set_state(current_state, States.JUMP)
		if (position.y-70)>next_y:
			jump_timer.start()
			#print("jump start")
			velocity.y = jump_velocity*1.2
			set_state(current_state, States.JUMP)


func handl_animation():
	var velocity_sign = sign(velocity.x)
	
	if velocity_sign < 0:
		animated_sprite_2d.flip_h = false
	else:
		animated_sprite_2d.flip_h = true	
	

func track_player():
	if player == null:
		return
	
	var direction_to_player : Vector2 = Vector2(player.position.x, player.position.y)\
	- player_tracking.position
	
	player_tracker_pivot.look_at(direction_to_player)

func handle_vision():
	#if player_tracking.is_colliding():
		#var collision_result = player_tracking.get_collider()
		#
		#if collision_result != player:
			#return
		#else:
			#set_state(current_state, States.CHASE)
			#chase_timer.start(1)
			#player_found = true
			#
	#else:
		#player_found = false
	player_found=true


func makepath() -> void:
	nav_agent.target_position = player.global_position
	#print("make_path")
		
	
func set_state(cur_state, new_state) -> void:
	var state
	if(cur_state == new_state):
		pass
	#elif new_state==States.ATTACK and cur_state==States.JUMP:
		#cur_state="AIR_ATTACK"
		#anim_player.play(attack_combo)
	else:
		current_state = new_state
		prev_state = cur_state
		
		match current_state:
			States.ATTACK:
				state="ATTACK"
				
				attacking=true
				#gravity=0
			States.WANDER:
				state="WANDER"
				hb_collison.disabled=false
				#print(str(prev_speed," ",current_speed))
				animation_player.speed_scale = 1
				animation_player.play("walking")
				if prev_state==States.JUMP:
					current_speed=prev_speed
			States.CHASE:
				hb_collison.disabled=false
				state="CHASE"
				animation_player.speed_scale =2
				animation_player.play("walking")
				if prev_state==States.JUMP:
					current_speed=prev_speed
			States.JUMP:
				if prev_state == States.WANDER:
					
					velocity.y = jump_velocity
					#print(str(prev_speed," ",current_speed))
					prev_speed=current_speed
					if current_speed < 0:
						current_speed = -jump_speed*2
					else:
						current_speed = jump_speed*2
				if prev_state == States.CHASE:
					velocity.y = jump_velocity*1.5
					#print(str(prev_speed," ",current_speed))
					prev_speed=current_speed
					if current_speed < 0:
						current_speed = -jump_speed
					else:
						current_speed = jump_speed
			States.PARRY:
				hb_collison.disabled=true
			States.DEATH:
				hb_collison.disabled=true
			
		
		#print(state)
		


func _on_health_health_depleted():
	var drop_inst=drop.instantiate()
	drop_inst.global_position = Vector2(position.x, position.y)
	get_tree().current_scene.add_child(drop_inst)
	Events.inc_score.emit()
	parried=false
	parry_timer.stop()
	set_state(current_state, States.DEATH)
	if animated_sprite_2d.flip_h==true:
		knockback.x = randi_range(500,800)*-1
	else:
		knockback.x = randi_range(500,800)
	knockback.y=randi_range(100,250)*-1
	
	death_timer.start()
	
	#if enemies.size() <=1:
		#Events.level_completed.emit()
		#print("level complete")
		#
func _on_death_timer_timeout():
	var explode_inst=explode.instantiate()
	explode_inst.global_position=Vector2(position.x, position.y)
	get_tree().current_scene.add_child(explode_inst)
	await get_tree().create_timer(0.1).timeout 
	queue_free()
	var enemies = get_tree().get_nodes_in_group("Enemy")


func _on_hurt_box_got_hit():
	health.set_temporary_immortality(0.2)
	
	

func _on_navigation_timer_timeout():
	makepath()
	#print("path_made")
	next_y=nav_agent.get_next_path_position().y
	var next_x=nav_agent.get_next_path_position().x
	#print(next_x)


func _on_hit_box_parried():
	current_state=States.PARRY
	print("PARRIED")
	parry_timer.start()
	if animated_sprite_2d.flip_h==true:
		knockback.x = -450
	else:
		knockback.x = 450
	await get_tree().create_timer(0.3).timeout
	set_state(current_state, States.PARRY)
	#velocity.y=jump_velocity/2
	parried = true
	
	


func _on_parry_timer_timeout():
	current_state=prev_state
	knockback = Vector2.ZERO
	parried=false
