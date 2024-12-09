extends CharacterBody2D
class_name PlayerEntity

@export var movement_data : PlayerMovementData
@export var health: Health
@export var hitbox: HitBox

enum States {IDLE, WALKING, JUMP, ATTACK, SPECIAL_ATTACK, WALL_STICK, PARRY, DODGE, SPRINTING}

var state: States = States.IDLE
var prev_state: States = States.IDLE

var double_jump_flag = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#wall jump state
var just_wall_jump = false
#parry state
var parry_stance=false
#attack combo up to 3
var atk_chain = 0
#true = facing right fals= facing left
var face_right = true
var input_dir=Input.get_axis("walk_left","walk_right")
#dodge dir
var dodge_state = false
var dodge_v = 0.0

var cur_state = "IDLE"

#Animation var
@onready var animated_sprite_2d = $AnimatedSprite2D

@onready var anim_player = $AnimationPlayer

@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var attack_timer = $AttackTimer
@onready var hit_timer = $HitTimer
@onready var parry_timer = $ParryTimer
@onready var dodge_timer = $DodgeTimer
@onready var starting_position : set = set_start_pos, get = get_start_pos
@onready var label = $STATE
@onready var hit_box = $HitBox
@onready var hb_right = $HitBox/HBRight
@onready var hb_left = $HitBox/HBLeft
@onready var pb_left = $ParryBox/PBLeft
@onready var pb_right = $ParryBox/PBRight
@onready var pb_rot = $ParryBox/PBRot
@onready var parry_box = $ParryBox

@onready var hurt_box_detect = $HurtBox/CollisionShape2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var hurt_box = $HurtBox
@onready var shotty = $AnimatedSprite2D/Shotty
@onready var sp_atk_hit_box = $AnimatedSprite2D/Shotty/SpAtkHitBox
@onready var sp_atk_cone = $AnimatedSprite2D/Shotty/SpAtkHitBox/SpAtkCone




var knockback : Vector2 = Vector2.ZERO
var kb_dir : Vector2 = Vector2.ZERO

var hit_box_pos

var attack_combo = "Attack"
var air_atk : bool = false
var s_atk : bool = false
var move_axis : int = 1
var sp_atk_type = sp_atk_cone

func _ready():
	hit_box_pos=hit_box.position
	hb_left.disabled=true
	hb_right.disabled=true
	pb_left.disabled=true
	pb_right.disabled=true
	pb_rot.disabled=true
	set_start_pos(global_position)
	sp_atk_type = sp_atk_cone
	load_player_data()
	Events.set_player_data.connect(save_player_data)
	Events.parried.connect(parry_success)
	

func _process(delta):
	var input_axis = Input.get_axis("walk_left", "walk_right")
	
	match state:
		States.ATTACK:
			#hit_timer.paused = false
			cur_state="ATTACK"
			set_state(state, States.ATTACK)
			#await anim_player.animation_finished
		States.SPECIAL_ATTACK:
			cur_state="SPECIAL_ATTACK"
			set_state(state, States.SPECIAL_ATTACK)
		States.IDLE:
			#hit_timer.start()
			#hit_timer.paused = true
			cur_state="IDLE"
			set_state(state, States.IDLE)
		States.WALKING:
			cur_state="WALKING"
			set_state(state, States.WALKING)
		States.JUMP:
			cur_state="JUMP"
		States.DODGE:
			cur_state="DODGE"
			set_state(state, States.DODGE)
		States.WALL_STICK:
			cur_state="WALL STICK"
		States.SPRINTING:
			cur_state = "SPRINTING"
		States.PARRY:
			cur_state = "PARRY"
			hurt_box_detect.disabled=true
			set_state(state, States.PARRY)
			
		
	dodge(input_axis, delta)
	if Input.is_action_just_pressed("walk_right"):
		face_right = true
		move_axis = 1
	elif Input.is_action_just_pressed("walk_left"):
		face_right = false
		move_axis = -1
	elif input_axis == 0:
		move_axis = 0
	
	handle_hitbox(input_axis, face_right)
	
	if(state!=States.DODGE and s_atk==false):
		parry()
		attack_animate()
		update_animation(input_axis)
	
	#print(air_atk)

func _physics_process(delta):
	
	if s_atk==true:
		pass
	else:
		if dodge_state == true:
			state = States.DODGE
		# Add the gravity.
		if(dodge_state==false):
			apply_gravity(delta) 
		var input_axis = Input.get_axis("walk_left", "walk_right")
		

		
		#print(dodge_timer.time_left)
		#print(parry_stance)
		var wall_hold = false
		if(state!=States.DODGE):
			handle_wall_jump(wall_hold, delta)
			jump(input_axis, delta)
			handle_acceleration(input_axis, delta)
			handle_air_acceleration(input_axis, delta)
			apply_friction(input_axis, delta)
			apply_air_resistance(input_axis, delta)
			sp_atk()
			if Input.is_action_pressed("sprint"):
				state=States.SPRINTING
				movement_data = load("res://FasterMovementData.tres")
			if Input.is_action_pressed("walk"):
				movement_data = load("res://SlowMovementData.tres")
			if Input.is_action_just_released("sprint") or Input.is_action_just_released("walk"):
				movement_data = load("res://DefaultMovementData.tres")
		
		if state==States.SPECIAL_ATTACK:
			velocity=Vector2.ZERO
			gravity=0
		#print(input_axis)
		
		var was_on_floor = is_on_floor()
		move_and_slide()
		var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
		if just_left_ledge:
			coyote_jump_timer.start()
		#if Input.is_action_pressed("sprint"):
			#state=States.SPRINTING
			#movement_data = load("res://FasterMovementData.tres")
		#if Input.is_action_pressed("walk"):
			#movement_data = load("res://SlowMovementData.tres")
		#if Input.is_action_just_released("sprint") or Input.is_action_just_released("walk"):
			#movement_data = load("res://DefaultMovementData.tres")
		just_wall_jump = false
		

		#print(hit_timer.time_left)
		label.text=str(atk_chain)
		
		
		knockback = lerp(knockback, Vector2.ZERO, 0.1)
		
		#wall hold check
		if not is_on_wall() or not Input.is_action_pressed("sprint"):
			wall_hold=false
			#print("wall hold false")
			gravity = 980
		else:
			#print("wall hold true")
			state = States.WALL_STICK
			velocity.x =0
			velocity.y = 0
			gravity = 0
		

# Add the gravity.
func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta
		
# Handle jump.
func jump(input_axis, delta):
	if is_on_floor(): double_jump_flag = true
	
	if is_on_floor() or coyote_jump_timer.time_left>0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = movement_data.jump_velocity
			
	elif not is_on_floor():
		state = States.JUMP
		if Input.is_action_just_released("jump") and velocity.y<movement_data.jump_velocity/2:
			velocity.y = movement_data.jump_velocity/2
		if Input.is_action_just_pressed("jump") and double_jump_flag == true and just_wall_jump == false:
			velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.acceleration*10 * delta)
			velocity.y = movement_data.jump_velocity *0.8
			double_jump_flag = false

func handle_wall_jump(wall_hold, delta):
	if not is_on_wall_only(): return
	if not Input.is_action_pressed("sprint"): return
	var wall_normal = get_wall_normal()

	
	if Input.is_action_just_pressed("walk_left") and wall_normal == Vector2.LEFT and wall_hold == true:
		state = States.WALL_STICK
		velocity.x =0
		velocity.y = 0
		gravity = 0
		
	elif Input.is_action_just_pressed("walk_right") or Input.is_action_just_pressed("jump") or Input.is_action_just_released("sprint"):
		state = States.JUMP
		velocity.x = move_toward(velocity.x, movement_data.speed * wall_normal.x * 1.5, movement_data.acceleration*10 * delta)
		velocity.y = movement_data.jump_velocity
		just_wall_jump = true
		
		
		
		
	if Input.is_action_just_pressed("walk_right") and wall_normal == Vector2.RIGHT and wall_hold == true:
		state = States.WALL_STICK
		velocity.x =0
		velocity.y = 0
		gravity = 0
	
	elif Input.is_action_just_pressed("walk_left") or Input.is_action_just_pressed("jump")  or Input.is_action_just_released("sprint"):
		state = States.JUMP
		velocity.x = move_toward(velocity.x, movement_data.speed * wall_normal.x * 1.5, movement_data.acceleration*10 * delta)
		velocity.y = movement_data.jump_velocity
		just_wall_jump = true
		
		
	
		
	if wall_hold == true:
		velocity.x =0
		velocity.y = 0
		gravity = 0
		print("wall hold true")
	else:
		gravity = 980



func apply_air_resistance(input_axis, delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0 , movement_data.air_resistance * delta)
# Get the input direction and handle the movement/deceleration.
func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)
		
# Apply friction after dtopping.
func handle_acceleration(input_axis, delta):
	if not is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.acceleration * delta)
		
func handle_air_acceleration(input_axis, delta):
	if is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.air_acceleration * delta)

func update_animation(input_axis):
	
	#var left = Input.is_action_pressed("walk_left")
	#var right = Input.is_action_pressed("walk_right")
	if input_axis != 0:
		
		#animated_sprite_2d.flip_h = (input_axis<0)
		if input_axis<0:
			if animated_sprite_2d.scale.x>0:
				animated_sprite_2d.scale.x *= -1
		else:
			if animated_sprite_2d.scale.x<0:
				animated_sprite_2d.scale.x *= -1
				
		if state != States.ATTACK and s_atk==false:
			state = States.WALKING
		#idle_state=false

	elif Input.is_action_just_released("walk_left") or Input.is_action_just_released("walk_right"):
		state = States.IDLE

		
		

	if not is_on_floor() and state != States.ATTACK:
		state = States.JUMP 
		
	elif is_on_floor() and state == States.JUMP:
		state = States.IDLE

		#animated_sprite_2d.play("jump")
	
		
		
func attack_animate():

	#if not hit_timer.is_stopped():
		#return
	
	#if Input.is_action_pressed("attack") and state != States.ATTACK:
		#hit_timer.start()
		#if attack_timer.is_stopped():
			#attack_timer.start()
		#
		#if not is_on_floor():
			#air_atk=true
		#
		#state=States.ATTACK
		#attack_timer.paused = true
		#
		#if atk_chain == 0 and (not attack_timer.is_stopped()):
			##animated_sprite_2d.play("attack_1")
			#attack_combo = "Attack"
			#
#
		#elif atk_chain == 1 and (not attack_timer.is_stopped()):
			##animated_sprite_2d.play("attack_2")
			#attack_combo = "Attack_2"
			#
#
		#elif atk_chain == 2 and (not attack_timer.is_stopped()):
			##animated_sprite_2d.play("attack_3")
			#attack_combo = "Attack_3"
			
#
	#elif (Input.is_action_just_released("attack")):
		##animated_sprite_2d.play("idle")
		#print("attack released")
		##anim_player.stop()
		#attack_timer.paused = false
		##state=States.IDLE
		

		#if atk_chain < 2:
			#
			#atk_chain += 1
			##print("Attack Chain")
		#elif atk_chain >=2:
			#atk_chain = 0
			#attack_combo = "Attack"
			##print("Attack Finished")
		
	if Input.is_action_just_pressed("attack") and state != States.ATTACK:
		attack_timer.start()
		attack_timer.paused=true
			
		if atk_chain == 0 and (not attack_timer.is_stopped()):
			#animated_sprite_2d.play("attack_1")
			attack_combo = "Attack"
			

		elif atk_chain == 1 and (not attack_timer.is_stopped()):
			#animated_sprite_2d.play("attack_2")
			attack_combo = "Attack_2"
			

		elif atk_chain == 2 and (not attack_timer.is_stopped()):
			#animated_sprite_2d.play("attack_3")
			attack_combo = "Attack_3"
			
			
		state=States.ATTACK
		set_state(state, States.ATTACK)
		
		await anim_player.animation_finished
		attack_timer.paused=false
		
		#if atk_chain < 2:
			#
			#atk_chain += 1
			##print("Attack Chain")
		#elif atk_chain >=2:
			#atk_chain = 0
			#attack_combo = "Attack"
			##print("Attack Finished")
		
			
	if Input.is_action_just_pressed("special_attack") and state != States.SPECIAL_ATTACK:
		
		if attack_timer.is_stopped():
			attack_timer.start()
		state=States.SPECIAL_ATTACK
		set_state(state, States.SPECIAL_ATTACK)
		attack_timer.paused = false
		s_atk=true
		await anim_player.animation_finished
		s_atk=false

	#elif (Input.is_action_just_released("special_attack")):
		#print("attack released")
		#attack_timer.paused = false
		#await anim_player.animation_finished
	#if not attack_timer.time_left > 0.0:
			#atk_chain = 0
			#attack_combo = "Attack"
			#print("Attack Restart")

func sp_atk():
	shotty.look_at(get_global_mouse_position())
	#sp_atk_hit_box.look_at(get_global_mouse_position())


func parry():
	parry_box.look_at(get_global_mouse_position())
	#Enter/Exit parry state
	if Input.is_action_just_pressed("parry"):
		parry_timer.start()
		parry_stance=true
		state=States.PARRY
		pb_rot.disabled=false
		#if face_right==true:
			#pb_left.disabled=false
		#if face_right==false:
			#pb_right.disabled=false

	elif Input.is_action_just_released("parry"):
		parry_timer.stop()
		parry_stance=false
		state=States.IDLE
		anim_player.stop()
		#idle_state = true
		
	
	#parry interactions
	if parry_stance==true:
		#animated_sprite_2d.play("parry_stance")
		velocity.x=0
		velocity.y=0

		
			
# DODGE NEEDS WORK!!!
func dodge(input_axis, delta):

	if Input.is_action_just_pressed("Dodge"):
		dodge_timer.start()
		if not is_on_floor():
			velocity.y=0
		
		if input_axis == 0:
			velocity.x=0
			state = States.DODGE
		else:
			position.x = lerpf(position.x, position.x + (input_axis*2), delta)
			state = States.DODGE
			
		#if input_axis == 0:
			#position.x = lerpf(position.x, position.x, delta)
			#state = States.DODGE
		#else:
			#if face_right==true:
				#position.x = lerpf(position.x, position.x-1, delta)
				#state = States.DODGE
				#
				#
			#elif face_right==false:
				#position.x = lerpf(position.x, position.x+1, delta)
				#state = States.DODGE
				#
		
	
	
	if (dodge_timer.is_stopped()) and state == States.DODGE:
		#parry_stance=false
		dodge_state=false
		dodge_timer.stop()
		state = States.IDLE
	
	
func handle_hitbox(input_axis, face_right):
	if state== States.ATTACK:
		if not face_right:
			hb_left.disabled=false
			hb_right.disabled=true
		else:
			hb_left.disabled=true
			hb_right.disabled=false

func _on_hazard_detector_area_entered(area):
	if area.is_in_group("hazard"):
		global_position=starting_position
		print("Health Depleted!")
		health.health -= 1
		print(health.health)
	elif area.is_in_group("Enemy"):
		print("enemy touched")
		knockback.x = input_dir.x * knockback.x *0.5

	
	
	
#State machine for animations currently
func set_state(current_state, new_state: int) -> void:
	if(current_state == new_state):
		pass
	
	if current_state==States.JUMP:
		air_atk=true
		print(air_atk)
	
	current_state=prev_state
	match state:
		States.ATTACK:
			#cur_state="ATTACK"
			anim_player.speed_scale=1.5
			anim_player.play(attack_combo)
			if air_atk==true:
			
				velocity=Vector2.ZERO
				gravity=0
				
		States.SPECIAL_ATTACK:
			anim_player.speed_scale=1.5
			anim_player.play("shotgun_attack")
			if not is_on_floor():
			
				velocity=Vector2.ZERO
				gravity=0
		States.IDLE:
			anim_player.speed_scale=1
			anim_player.play("idle")
			movement_data.friction=1000
			hb_left.disabled=true
			hb_right.disabled=true
		States.WALKING:
			anim_player.speed_scale=1
			anim_player.play("walk")
		States.JUMP:
			anim_player.play("jump")
			cur_state="JUMP"
		States.DODGE:
			hurt_box_detect.disabled=true
			anim_player.speed_scale=1
			anim_player.play("dodge")
			velocity.y=0
			#velocity.x=100 * move_axis
		States.PARRY:
			anim_player.play("Parry")
			
	if state != States.DODGE:
		hurt_box_detect.disabled=false
			
			
				
			
	if state!=States.PARRY:
		pb_rot.disabled=true
		pb_left.disabled=true
		pb_right.disabled=true
func get_state() -> String:
	return cur_state

func get_health() -> int:
	return health.health

func _on_health_health_depleted():
	Events.game_over.emit()

#knockbacks
#func _on_hurt_box_knockback(hitbox):
	##kb_dir=global_position.direction_to(hitbox.global_position)
	##print("knockback")
	##kb_dir=round(kb_dir)
	##print(kb_dir.x, " ", knockback)

func _on_hurt_box_got_hit(hitbox):
	knockback.x = -350
	kb_dir=global_position.direction_to(hitbox.global_position)
	#print("knockback")
	kb_dir=round(kb_dir)
	#print(kb_dir.x, " ", knockback)
	knockback.x = kb_dir.x * knockback.x
	velocity.y=movement_data.jump_velocity/2
	velocity.x = movement_data.speed + knockback.x
	health.set_temporary_immortality(0.2)

func _on_hurt_box_area_entered(area):
	if area.is_in_group("bullet"):
		knockback.x = -350
		kb_dir=global_position.direction_to(area.global_position)
		#print("knockback")
		kb_dir=round(kb_dir)
		#print(kb_dir.x, " ", knockback)
		knockback.x = kb_dir.x * knockback.x
		velocity.y=movement_data.jump_velocity/2
		velocity.x = movement_data.speed + knockback.x
		health.health -= 1
		health.set_temporary_immortality(0.2)
		
	if area.is_in_group("Hearts"):
		health.health+=1
		
	elif area.is_in_group("Enemy"):
		pass
	

#Setting starting positions for level starts and checkpoints
func get_start_pos():
	return starting_position

func set_start_pos(checkpoint_position):
	starting_position=checkpoint_position



func _on_animation_player_animation_finished(anim_name):
	if state==States.ATTACK:
		print("attack finished")
		if atk_chain < 2:
			
			atk_chain += 1
			#print("Attack Chain")
		elif atk_chain >=2:
			atk_chain = 0
			attack_combo = "Attack"
			#print("Attack Finished")
		
		state=prev_state
	elif state==States.SPECIAL_ATTACK:
		if anim_name=="shotgun_attack":
			print("special finished")
			s_atk=false
			state=States.IDLE
			#set_state(state, States.IDLE)

func _on_attack_timer_timeout():
	atk_chain = 0
	attack_combo = "Attack"
	#s_atk=false

func load_player_data():
	var file = FileAccess.open("user://player_data/stats/player_stats.txt", FileAccess.READ)
	if file.file_exists("user://player_data/stats/player_stats.txt"):
		while file.is_open():
			var content = file.get_line()
			var stat : String = content.get_slice(":", 0)
			var stat_val : int = int(content.get_slice(":", 1))
			print(stat, ": ", str(stat_val))
			if stat != null:
				match stat:
					"health":
						health.set_health(stat_val)
					"max_health":
						health.set_max_health(stat_val)
			if file.eof_reached():
				break
		file.close()
	else:
		print("file not found")

func save_player_data():
	var file = FileAccess.open("user://player_data/stats/player_stats.txt", FileAccess.READ_WRITE)
	if file.file_exists("user://player_data/stats/player_stats.txt"):
		var stat : String = str("health: ", health.get_health())
		file.store_string(stat)
		file.store_string("\n")
		stat = str("max_health: ", health.get_max_health())
		file.store_string(stat)
		file.store_string("\n")
		file.close()
	else:
		print("file not found")


func _on_parry_timer_timeout():
	state=States.IDLE
	anim_player.stop()
	
func parry_success():
	parry_timer.stop()
	anim_player.play("Parry_Success")
	print("parry success")
	await anim_player.animation_finished
	anim_player.stop()

