extends CharacterBody2D


const SPEED = 30.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var hit_box = $HitBox
@onready var animation_player = $AnimationPlayer
@onready var bt_player = $BTPlayer
@onready var hbsb = $HBSB
@onready var health = $Health
@onready var stagger = $Stagger
@onready var jump_timer = $JumpTimer
@onready var parry_timer = $ParryTimer
@onready var chase_timer = $ChaseTimer
@onready var hb_col = $HitBox/CollisionShape2D
@onready var attack_timer = $AttackTimer
@onready var player_tracker_pivot = $PlayerTrackerPivot
@onready var player_tracking = $PlayerTrackerPivot/PlayerTracking

var player_found : bool = false
var player : PlayerEntity = null

#shooting
@onready var turret = $Turret
@onready var turret_body = $Turret/TurretBody
@onready var bullet = preload("res://Component/wave_projectile.tscn")



var atk : int = 1
var atk_cmb : String = "attack_1"
var counter_speed : int = 1
var parried : bool = false
var fleeing : bool = false
var full_combo : bool = false
var phase : int = 0



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var knockback : Vector2 = Vector2.ZERO

func _ready():
	player = get_tree().get_first_node_in_group("player")
	bt_player.blackboard.set_var("stunned", false)
	bt_player.blackboard.set_var("flee", false)
	phase = 0
	bt_player.blackboard.set_var("phase", phase)
	turret.setup(3)
	turret_body.visible=true
	

func _process(delta):
	var h = health.get_health()
	var s = stagger.get_stagger()
	
	hbsb.text=str("H: ",h," STG: ",s)
	turret.track_player()
	
	if phase == 1:
		turret.shoot()
		turret.shoot_timer.paused=false
		
	if health.health<=5:
		set_phase(phase, 1)
	
	if bt_player.blackboard.get_var("phase") != phase:
		bt_player.blackboard.set_var("phase", phase)
	
	
	#elif fleeing == false:
		#turret.shoot_timer.paused=true
	

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	#move(-1, SPEED)
	bt_player.blackboard.set_var("full_combo", full_combo)

	handle_vision()
	track_player()
	move_and_slide()
	
	

func move(dir, speed):
	velocity.x = (dir * (speed * counter_speed)) + knockback.x
	
	if phase==1:
		if position.y>20:
			print("floaitng")
			position.y -= 1
		velocity.y=0
		gravity=0
		#global_position.y=100
	
	knockback = lerp(knockback, Vector2.ZERO, 0.1)
	
	handle_animation(dir)
	
func handle_vision():
	player_found=true
	
func track_player():
	if player == null:
		return
	
	var direction_to_player : Vector2 = Vector2(player.position.x, player.position.y)\
	- player_tracking.position
	var dir_bullet = (to_local(player.position) - turret_body.position)
	
	player_tracker_pivot.look_at(direction_to_player)
	
	turret_body.rotation=dir_bullet.angle()
func handle_animation(dir):
	if abs(dir) != dir:
		animated_sprite_2d.scale.x = 1
		hit_box.scale.x = 1
	else:
		animated_sprite_2d.scale.x = -1
		hit_box.scale.x = -1

func light_attack():
	animation_player.play("light_attack")
	await animation_player.animation_finished

func attack_combo():
	#var tree_status = bt_player.get_last_status()
	#print(tree_status)
	if attack_timer.is_stopped():
		attack_timer.start()
		atk_cmb=str("attack_",atk)
		animation_player.play(atk_cmb)
		await animation_player.animation_finished
		
	

func _on_hit_box_parried():
	
		
	if stagger.stagger >= 1:
		if animated_sprite_2d.flip_h==true:
			knockback.x = 200
		else:
			knockback.x = -200
	else:
		if animated_sprite_2d.flip_h==true:
			knockback.x = 45
		else:
			knockback.x = -45
	
	if bt_player.blackboard.get_var("light_attack")==true:
		turret.setup(0.3)
		fleeing=true
		bt_player.blackboard.set_var("flee", true)
	elif bt_player.blackboard.get_var("light_attack")==false:
		if atk >= 3:
			atk = 1
		else:
			atk += 1
			

func _on_stagger_staggered():
	
	hb_col.disabled=true
	parry_timer.start()
	bt_player.blackboard.set_var("stunned", true)
	bt_player.blackboard.set_var("full_combo", false)
	full_combo=false
	

func _on_parry_timer_timeout():
	hb_col.disabled=false
	bt_player.blackboard.set_var("stunned", false)
	



func _on_animation_player_animation_finished(anim_name):
	
	#var atk_chg : int = randi_range(0,5)
	if anim_name=="light_attack":
		full_combo=true
		#print("light attacked ", atk_chg)
		#if atk_chg < 0:
			#bt_player.blackboard.set_var("full_combo", false)
		#else:
			#print("full combo ready")
			#bt_player.blackboard.set_var("full_combo", true)
			
	#if anim_name=="attack_3":
		#bt_player.blackboard.set_var("full_combo", false)



func _on_turret_shoot_bullet():
	print("shoot")
	var bullet_inst = bullet.instantiate()
	bullet_inst.set_speed(300.0)
	bullet_inst.dir = (turret.player_tracker.target_position).normalized()
	bullet_inst.spawnPos = Vector2(position.x, position.y)
	bullet_inst.spawnRot = turret_body.rotation
	get_tree().current_scene.add_child(bullet_inst)


func _on_bt_player_updated(status):
	if status==3:
		fleeing=false

func set_phase(cur_phase, next_phase : int):
	print("next phase")
	print(cur_phase, " ",next_phase)
	if cur_phase==next_phase:
		return
	else:
		bt_player.restart()
		bt_player.blackboard.set_var("stunned", false)
		phase=next_phase
		bt_player.blackboard.set_var("phase", phase)
