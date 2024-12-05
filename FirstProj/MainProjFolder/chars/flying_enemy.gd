extends CharacterBody2D

const SPEED = 40
const BALL_PROCETILE = preload("res://Component/ball_procetile.tscn")

@onready var player : PlayerEntity = null
@onready var nav_agent := $NavigationAgent2D2 as NavigationAgent2D
@onready var player_tracker_pivot = $PlayerTrackerPivot
@onready var player_tracking = $PlayerTrackerPivot/PlayerTracking
@onready var jump_timer = $JumpTimer
@onready var parry_timer = $ParryTimer
@onready var chase_timer = $ChaseTimer
@onready var turret = $Turret
@onready var animation_player = $AnimationPlayer
@onready var bullet = BALL_PROCETILE
@onready var bullet_dir = Vector2.RIGHT
@onready var audio_stream_player_2d = $AudioStreamPlayer2D
@onready var stagger = $Stagger
@onready var hb_detect = $HitBox/CollisionShape2D

@onready var stg_laber = $stg_laber

@onready var death_timer = $DeathTimer

@export var drop = preload("res://heart.tscn")
@export var explode = preload("res://Component/explosion.tscn")


var player_found : bool = false
var found : bool = false
var knockback : Vector2 = Vector2.ZERO

enum States{
	WANDER,
	CHASE,
	STAGGERED,
	DEATH
}
var current_state = States.CHASE
var prev_state = States.CHASE

var state : String

func _ready():
	player = get_tree().get_first_node_in_group("player")
	animation_player.play("default")
	turret.setup(2)
	turret.shoot_timer.paused=true
	player_found=true
	found=true
	hb_detect.disabled=true
	
func _process(delta):
	track_player()
	handle_vision()
	#print(current_state)
	stg_laber.text=str("Stagger: ", stagger.get_stagger(), " ", state)
	
	
func _physics_process(delta):
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	
	var vel_y_default = velocity.y
	var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	
	if found:
		move_and_slide()
	
	if current_state==States.CHASE:
		velocity = dir * SPEED
		turret.shoot()
		turret.shoot_timer.paused=false
		#gravity=0
		#velocity.y = vel_y_default
		
	elif current_state==States.STAGGERED:
		#move_and_slide()
		velocity.y = gravity * 0.3
		velocity.x=0
		turret.shoot_timer.paused=true
		#print("staggered")
	elif current_state==States.DEATH:
		#move_and_slide()
		velocity.y = knockback.y
		velocity.x = dir.x*(-1)*knockback.x
	#if knockback != Vector2.ZERO:
		
	print(velocity)
		
	
	knockback = lerp(knockback, Vector2.ZERO, 0.1)
	#makepath()
	
	
func makepath() -> void:
	nav_agent.target_position = player.global_position

func handle_vision():
	#if player_tracking.is_colliding():
		#var collision_result = player_tracking.get_collider()
		#
		#if collision_result != player:
			#return
		#else:
			#if parry_timer.is_stopped():
				#set_state(current_state, States.CHASE)
				##chase_timer.start(1)
				#player_found = true
				#found = true
				##print("found")
			#
	#else:
		#player_found = false
	player_found=true
func track_player():
	if player == null:
		return
	
	var direction_to_player : Vector2 = Vector2(player.position.x, player.position.y)\
	- player_tracking.position
	
	player_tracker_pivot.look_at(direction_to_player)
func set_state(cur_state, new_state) -> void:

	if(cur_state == new_state):
		pass
	elif(cur_state==States.DEATH):
		pass
	#elif new_state==States.ATTACK and cur_state==States.JUMP:
		#cur_state="AIR_ATTACK"
		#anim_player.play(attack_combo)
	else:
		current_state = new_state
		prev_state = cur_state
		
		match current_state:
			
			States.WANDER:
				state="WANDER"
			States.CHASE:
				state="CHASE"
			States.STAGGERED:
				state="STAGGERED"
				#animation_player.play("attack")
				#await animation_player.animation_finished
		
		#print(state)

func _on_nav_timer_timeout():
	makepath()


func _on_health_health_depleted():
	Events.inc_score.emit()
	parry_timer.stop()
	set_state(current_state, States.DEATH)
	knockback.y=(randi_range(100,400)*-1)
	knockback.x=(randi_range(500,900))
	print(knockback)
	death_timer.start()
	

func _on_death_timer_timeout():
	var drop_inst=drop.instantiate()
	drop_inst.global_position = Vector2(position.x, position.y)
	get_tree().current_scene.add_child(drop_inst)
	var explode_inst=explode.instantiate()
	explode_inst.global_position=Vector2(position.x, position.y)
	get_tree().current_scene.add_child(explode_inst)
	await get_tree().create_timer(0.1).timeout 
	queue_free()
	var enemies = get_tree().get_nodes_in_group("Enemy")

func _on_turret_shoot_bullet():
	#print("shoot")
	var bullet_inst = bullet.instantiate()
	bullet_inst.set_speed(300.0)
	bullet_inst.dir = (turret.player_tracker.target_position).normalized()
	bullet_inst.spawnPos = Vector2(position.x, position.y)
	audio_stream_player_2d.play()
	
	get_tree().current_scene.add_child(bullet_inst)



func _on_hurt_box_area_entered(area):
	if area.is_in_group("sp_atk_default"):
		#print("spc_hit")
		stagger.stagger -= 1


func _on_stagger_staggered():
	set_state(current_state, States.STAGGERED)
	parry_timer.start()
	
	#parry_timer.paused=true


func _on_parry_timer_timeout():
	set_state(current_state, prev_state)
	


