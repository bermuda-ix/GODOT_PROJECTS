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
@onready var flee_timer = $FleeTimer as Timer
@onready var animated_sprite_2d = $AnimatedSprite2D as AnimatedSprite2D
@onready var sword_sprite = $AnimatedSprite2D/AnimatedSprite2D
@onready var animation_player = $AnimationPlayer as AnimationPlayer
@onready var turret = $Turret
@onready var bullet = preload("res://Component/wave_projectile.tscn")
@onready var turret_body = $Turret/TurretBody


@onready var floor_jump_check_right = $JumpChecks/FloorJumpCheckRight as RayCast2D
@onready var floor_jump_check_left = $JumpChecks/FloorJumpCheckLeft as RayCast2D
@onready var gap_check_left = $JumpChecks/GapCheckLeft as RayCast2D
@onready var gap_check_right = $JumpChecks/GapCheckRight as RayCast2D
@onready var leap_up_check_left = $JumpChecks/LeapUpCheckLeft as RayCast2D
@onready var leap_up_check_right = $JumpChecks/LeapUpCheckRight as RayCast2D

@onready var health = $Health
@onready var hurt_box = $HurtBox
@onready var hit_box = $HitBox
@onready var hb_collison = $HitBox/CollisionShape2D
#@onready var h_bar = $HBar
@onready var parry_timer = $ParryTimer as Timer
var immortal = false
@onready var stagger = $Stagger

@onready var hb_sb = $HB_SB
var stg_cnt : int = 1

var attack_type_range : int = 5
@onready var attack_type : int = randi() % 5
@onready var light_attack : bool = false


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
var attack_combo : int = 1
var atk_anim : String = "attack_1"

var state

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum States{
	CHASE,
	JUMP,
	ATTACK,
	RANGE,
	PARRY,
	FLEE
}

var current_state = States.FLEE
var prev_state = States.CHASE

func _ready():
	#chase_timer.timeout.connect(on_timer_timeout)
	player = get_tree().get_first_node_in_group("player")
	set_state(current_state, States.CHASE)
	#animation_player.play("walking")
	stg_cnt=stagger.get_max_stagger()
	#hb_collison.disabled = true
	turret.setup()
	turret_body.visible=false
	flee_timer.stop()
	
	
	
func _process(_delta):
	#health_bar()
	#if current_state != States.PARRY:
		#hb_collison.disabled=false
	#hb_collison.disabled = true
	turret.track_player()
	#turret.rotate_bullet()
	turret.shoot()
	
	#if flee_timer.is_stopped() and current_state==States.FLEE:
		#set_state(current_state, prev_state)
		
	
	
	#print(turret.direction_to_player)
	if current_state != States.ATTACK:
		handle_vision()
		track_player()
	#match current_state:
		#States.WANDER:
			#set_state(current_state, States.WANDER)
		#States.ATTACK:
			#set_state(current_state, States.ATTACK)
	match attack_combo:
		1:
			atk_anim="attack_1"
		2:
			atk_anim="attack_2"
		3:
			atk_anim="attack_3"
	var h = health.get_health()
	var s = stagger.get_stagger()
	
	#hb_sb.text=str("Health: ",h,"Stagger: ",s )
	hb_sb.text=str("State: ", state)
	#if flee_timer.is_stopped():
		#light_attack=false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

#for testing remove later
	#hb_collison.disabled = true
	
	
	if knockback == Vector2.ZERO or parried==false:
		handle_movement()
		
	if parry_timer.is_stopped() :
		#current_state=prev_state
		knockback = Vector2.ZERO
		parried=false
		
	
	handl_animation()

	velocity.x = current_speed + knockback.x
	
	if parried == true:
		hb_collison.disabled=true
		velocity.x=0
	
	if attacking==false:
		move_and_slide()
		#hb_collison.disabled=false
		
	knockback = lerp(knockback, Vector2.ZERO, 0.1)
	
func handle_movement() -> void:
	var direction
	if flee_timer.is_stopped():
		direction= global_position - player.global_position
	else:
		direction= player.global_position - global_position
	
	
	if current_speed == States.ATTACK:
		current_speed = 0

	
	elif current_state == States.CHASE:
		if player.position.y<position.y:
			if (not floor_checks_right.is_colliding()) and (floor_jump_check_right.is_colliding()) and is_on_floor(): 
				velocity.y = jump_velocity
				
				#current_state=States.JUMP
				
			if (not floor_checks_left.is_colliding()) and (floor_jump_check_left.is_colliding()) and is_on_floor():
				velocity.y = jump_velocity
				
			#current_state=States.JUMP
		
		if ( (leap_up_check_right.is_colliding() and current_speed>0 ) or (leap_up_check_left.is_colliding() and current_speed<0 ) ) and position.y-30>player.position.y:
			velocity.y = jump_velocity*1.2
		#
		if direction.x < 0:
			current_speed = chase_speed
		else:
			current_speed = -chase_speed
	
	elif current_state == States.JUMP:
		if is_on_floor():
			set_state(current_state, prev_state)
			#current_speed=prev_speed
		#velocity.y = jump_velocity
		#current_speed=0.0
		#prev_state=States.JUMP
		
	elif current_state == States.PARRY:
		current_speed=0
	velocity.x = current_speed

	
func handl_animation():
	var velocity_sign = sign(velocity.x)
	
	if flee_timer.is_stopped():
		if velocity_sign < 0:
			animated_sprite_2d.scale.x = 1
			hit_box.scale.x = 1
		else:
			animated_sprite_2d.scale.x = -1
			hit_box.scale.x = -1
		
func track_player():
	if player == null:
		return
	
	var direction_to_player : Vector2 = Vector2(player.position.x, player.position.y)\
	- player_tracking.position
	var dir_bullet = (to_local(player.position) - turret_body.position)
	
	player_tracker_pivot.look_at(direction_to_player)
	
	turret_body.rotation=dir_bullet.angle()
	

func handle_vision():
	player_found=true



func set_state(cur_state, new_state) -> void:
	
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
				animation_player.speed_scale = 1
				attacking=true
			States.CHASE:
				print("chasing")
				#hb_collison.disabled=false
				#turret.shoot_timer.paused=true
				#turret.shoot_timer.start(3)
				state="CHASE"
				animation_player.speed_scale =2
				#animation_player.play("walking")
				if prev_state==States.JUMP:
					current_speed=prev_speed
			States.JUMP:
				velocity.y = jump_velocity*1.5
				print(str(prev_speed," ",current_speed))
				prev_speed=current_speed
				if current_speed < 0:
					current_speed = -jump_speed
				else:
					current_speed = jump_speed
			States.PARRY:
				hb_collison.disabled=true
	
			States.FLEE:
				flee_timer.start()
				#turret.shoot_timer.paused=false
				turret.shoot_timer.start(.5)
		#print(state)




func _on_attack_range_body_entered(body):
	if parried != true:
		print("attack in range")
		turret.shoot_timer.paused=true
		set_state(current_state, States.ATTACK)
		attack_type = randi() % attack_type_range
		print(attack_type)
		
		if attack_type <= 1:  
			animation_player.play(atk_anim)
			attacking=true
			light_attack=false
			#hb_collison.disabled=true
			await animation_player.animation_finished
			if attack_combo<3:
				attack_combo+=1
			else:
				attack_combo=1
				
		else:
			animation_player.play("light_attack")
			attacking=true
			light_attack=true
			#hb_collison.disabled=true
			await animation_player.animation_finished
		
		print("attack finished")
		set_state(prev_state, States.CHASE)
		#hb_collison.disabled=false
		attacking=false
		turret.shoot_timer.paused=true


func _on_hit_box_parried():
	attacking=false
	animation_player.play("RESET")
	if animated_sprite_2d.flip_h==true:
		knockback.x = 450
	else:
		knockback.x = -450
	
	
	
	velocity.y=jump_velocity/2
	velocity.x = current_speed + knockback.x
	#print(knockback)
	
	if light_attack == true and parried == false:
		
		set_state(current_state, States.FLEE)
		attack_combo=1
	else:
		parry_timer.start()
	##velocity.y=jump_velocity/2
	#if stg_cnt <= 1:
		#stg_cnt=stagger.get_max_stagger()
		#parried = true
	#else:
		#stg_cnt -= 1
		



func _on_stagger_staggered():
	parried = true
	turret.shoot_timer.paused=true
	current_state=States.PARRY
	print("PARRIED")
	flee_timer.stop()
	await get_tree().create_timer(0.3).timeout
	set_state(current_state, States.PARRY)

func _on_health_health_depleted():
	queue_free()
	var enemies = get_tree().get_nodes_in_group("Enemy")
	if enemies.size() <=1:
		Events.level_completed.emit()
		print("level complete")
		



func _on_turret_shoot_bullet():
	print("shoot")
	var bullet_inst = bullet.instantiate()
	bullet_inst.set_speed(300.0)
	bullet_inst.dir = (turret.player_tracker.target_position).normalized()
	bullet_inst.spawnPos = Vector2(position.x, position.y-25)
	bullet_inst.spawnRot = turret_body.rotation
	get_tree().current_scene.add_child(bullet_inst)


func _on_flee_timer_timeout():
	turret.shoot_timer.start(3)
	if parried != false:
		set_state(current_state, States.CHASE)


func _on_parry_timer_timeout():
	set_state(current_state, States.CHASE)
	turret.shoot_timer.paused=false




func _on_animation_player_animation_finished(anim_name):
	if anim_name == atk_anim or anim_name == "light_attack":
		set_state(current_state, States.CHASE)
