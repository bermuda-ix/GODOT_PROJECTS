extends CharacterBody2D


const SPEED = 30.0
const JUMP_VELOCITY = -400.0
#bullets:
const BALL_PROCETILE = preload("res://Component/ball_procetile.tscn")
const WAVE_PROJECTILE = preload("res://Component/wave_projectile.tscn")


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
@onready var shoot_change_timer = $ShootChangeTimer
@onready var hb_col = $HitBox/CollisionShape2D
@onready var attack_timer = $AttackTimer
@onready var player_tracker_pivot = $PlayerTrackerPivot
@onready var player_tracking = $PlayerTrackerPivot/PlayerTracking

var player_found : bool = false
var player : PlayerEntity = null

#shooting
@onready var turret = $Turret
@onready var turret_body = $Turret/TurretBody
@onready var bullet = WAVE_PROJECTILE
@onready var bullet_dir = Vector2.RIGHT
@onready var clkckws : bool = true
@onready var arc_shot : bool = true
@onready var multi_shot : bool = true
@onready var final_hit : bool = false

@export var center : Vector2 = Vector2(272,60)

var atk : int = 1
var atk_cmb : String = "attack_1"
var counter_speed : int = 1
var parried : bool = false
var fleeing : bool = false
var full_combo : bool = false
var phase : int = 0
var chase : bool = false
var final_phase_hit : int = 0


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var grav=gravity
var knockback : Vector2 = Vector2.ZERO

func _ready():
	player = get_tree().get_first_node_in_group("player")
	bt_player.blackboard.set_var("stunned", false)
	bt_player.blackboard.set_var("flee", false)
	phase = 0
	bt_player.blackboard.set_var("phase", phase)
	bt_player.blackboard.set_var("final_hit", false)
	turret.setup(3)
	turret_body.visible=false
	chase_timer.start(5)
	bullet = WAVE_PROJECTILE
	turret.set_multi_shot(false)
	multi_shot=false
	bt_player.blackboard.set_var("multi_shot", false)
	
	#for testing, to be removed

	#turret.set_multi_shot(false)
	#multi_shot=false
	#bt_player.blackboard.set_var("multi_shot", false)
	#turret.setup(.1)
	#shoot_change_timer.start(3)
	#bullet=BALL_PROCETILE

func _process(delta):
	var h = health.get_health()
	var s = stagger.get_stagger()
	
	hbsb.text=str("H: ",h," STG: ",s)
	turret.track_player()
	
	if phase == 1:
		if position.y<70:
			if bt_player.blackboard.get_var("charge")==false:	
				#print(turret.shoot_timer.time_left)
				turret.shoot()
				turret.shoot_timer.paused=false
			else:
				turret.shoot_timer.paused=true
	elif phase == 2:
		
		if global_position.y<70 and final_phase_hit<10:
			if bt_player.blackboard.get_var("charge")==false and not multi_shot:
				bt_player.blackboard.set_var("multi_shot", false)
				turret.shoot()
				turret.shoot_timer.paused=false
			else:
				bt_player.blackboard.set_var("multi_shot", true)
				turret.shoot_timer.paused=true
				#spread_shot(15)
		
	if final_hit==true:
		bt_player.blackboard.set_var("final_hit", true)
	else:
		bt_player.blackboard.set_var("final_hit", false)
		
	if health.health<=5 and health.health>1:
		set_phase(phase, 1)
	elif health.health<=1:
		set_phase(phase, 2)
	
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
	rotate_bullet()
	if phase==2:
		center_fly()
	move_and_slide()
	
	#if phase==2 and final_hit==false:
		#if (global_position.x!=176 or global_position.y>20) and bt_player.blackboard.get_var("charge")==false:
			##print("moving to center")
			#gravity=0
			#global_position.x=lerpf(global_position.x, 176, .1)
			#global_position.y=lerpf(global_position.y, 20, .1)
		#
	#elif phase==2 and final_hit==true:
		#gravity=grav
		#
	#print(bt_player.blackboard.get_var("multi_shot"))
	

func move(dir, speed):
	
	#velocity.y = (dir * (speed * counter_speed))
	#print(phase)
	if phase==0:
		velocity.x = (dir * (speed * counter_speed)) + knockback.x
		gravity=grav
			#var direction = global_position - player.global_position
		velocity.y = speed
	elif phase==1:
		velocity.x = (dir * (speed * counter_speed)) + knockback.x
		if position.y>60 and bt_player.blackboard.get_var("charge")==false:
			#print("floaitng")
			position.y -= 1
			velocity.y=0
			gravity=0
		elif (not is_on_floor()) and bt_player.blackboard.get_var("charge")==true:
			#position.y += 1
			
			gravity=grav
			#var direction = global_position - player.global_position
			velocity.y = speed
		
	elif phase==2:
		#print("moving phase 2")
		if final_hit==true:
			velocity.x = (dir * (speed * counter_speed)) + knockback.x
			gravity=grav
				#var direction = global_position - player.global_position
			velocity.y = speed
			
	else:
		velocity.x = (dir * (speed * counter_speed)) + knockback.x
		gravity=grav
		#var direction = global_position - player.global_position
		velocity.y = speed
	
	#elif phase==2:
		#
		##global_position.y=100
	
	knockback = lerp(knockback, Vector2.ZERO, 0.1)

	
	handle_animation(dir)

func center_fly():
	if (global_position.x!=272 or global_position.y>40) and final_hit==false:
		#print("moving to center")
		gravity=0
		global_position.x=lerpf(global_position.x, center.x, .1)
		global_position.y=lerpf(global_position.y, center.y, .1)
	elif final_hit==true:
		gravity=grav

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
	velocity.x=0

func attack_combo():
	#var tree_status = bt_player.get_last_status()
	#print(tree_status)
	if attack_timer.is_stopped():
		attack_timer.start()
		atk_cmb=str("attack_",atk)
		animation_player.play(atk_cmb)
		await animation_player.animation_finished
		

func rotate_bullet():
	
	var bd_angel=bullet_dir.angle()
	if clkckws:
		#print("clockwise: ", bullet_dir.angle())
		bullet_dir = bullet_dir.slerp(Vector2.LEFT, 0.02) 
	else :
		#print("counterclockwise: ", bullet_dir.angle())
		bullet_dir = bullet_dir.slerp(Vector2.RIGHT, 0.02) 

	if bd_angel <= 0.3 and not clkckws:
		clkckws = true
	elif bd_angel >= 2.8 and clkckws:
		clkckws = false
	

func spread_shot(value: float):
	print("spread shot")
	var shots = 180/value
	var bd_angle=0
	for n in shots:
		bullet_dir=bullet_dir.rotated(deg_to_rad(bd_angle))
		turret.shoot()
		bd_angle+=shots
		#print(shots)


func _on_hit_box_parried():
	
	
	
	bt_player.restart()
	if phase == 1:
		chase_timer.start(5)
		chase_timer.paused = false
		bt_player.blackboard.set_var("flee", true)
		bt_player.blackboard.set_var("charge", false)
	#chase_timer.pause=false
	elif phase == 2:
		bullet = BALL_PROCETILE
		turret.setup(3)
		chase_timer.start(5)
		chase_timer.paused = false
		#bt_player.blackboard.set_var("flee", true)
		bt_player.blackboard.set_var("charge", false)
	if phase != 2:
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
	else:
		if animated_sprite_2d.flip_h==true:
			knockback.x = 600
		else:
			knockback.x = -600
	#if bt_player.blackboard.get_var("light_attack")==true:
		#turret.setup(0.3)
		#fleeing=true
		#bt_player.blackboard.set_var("flee", true)
	#elif bt_player.blackboard.get_var("light_attack")==false:
		
	if atk >= 3:
		atk = 1
	else:
		atk += 1
			
func _on_stagger_staggered():
	
	hb_col.disabled=true
	parry_timer.start()
	animation_player.play("RESET")
	velocity=Vector2.ZERO
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
	#print("shoot")
	var bullet_inst = bullet.instantiate()
	bullet_inst.set_speed(300.0)
	if phase != 2:
		bullet_inst.dir = (turret.player_tracker.target_position).normalized()
		bullet_inst.spawnRot = turret_body.rotation
	else:
		bullet_inst.dir = (bullet_dir)
		bullet_inst.spawnRot = bullet_dir.angle()
	bullet_inst.spawnPos = Vector2(position.x, position.y)
	
	
	get_tree().current_scene.add_child(bullet_inst)


func _on_bt_player_updated(status):
	if status==3:
		fleeing=false
		chase_timer.paused=false
		if chase_timer.is_stopped():
			chase_timer.start(5)
		
	#if phase==2:
		#bt_player.active=false
		#print("final hit")

func set_phase(cur_phase, next_phase : int):
	
	if cur_phase==next_phase:
		return
	else:
		print("next phase")
		print(cur_phase, " ",next_phase)
		chase_timer.start(5)
		bt_player.restart()
		bt_player.blackboard.set_var("stunned", false)
		phase=next_phase
		chase_timer.paused=false
		bt_player.blackboard.set_var("phase", phase)
		if next_phase == 2:
			turret.setup(.1)
			shoot_change_timer.start(5)
			turret.shoot_timer.paused=false
			bullet=BALL_PROCETILE


func _on_chase_timer_timeout():
	bt_player.blackboard.set_var("attack_timer", true)


func _on_shoot_change_timer_timeout():
	
	if phase != 2:
		return
	else:
		print(final_phase_hit)
		var time=randf_range(3,5)
		final_phase_hit += 1
		if final_phase_hit >=10:
			bt_player.blackboard.set_var("multi_shot", false)
			bt_player.blackboard.set_var("final_hit", true)
			final_hit=true
			multi_shot=false
			turret.shoot_timer.paused=false
		
		else:
			
			if multi_shot:
				multi_shot = false
				turret.set_multi_shot(false)
				shoot_change_timer.start(time)
				bullet=BALL_PROCETILE
			else:
				multi_shot=true
				turret.set_multi_shot(true)
				bullet=WAVE_PROJECTILE
				shoot_change_timer.start(time)
			print("MS: ",multi_shot)


func _on_health_health_depleted():
	queue_free()
	var enemies = get_tree().get_nodes_in_group("Enemy")
	if enemies.size() <=1:
		Events.level_completed.emit()
		print("level complete")
