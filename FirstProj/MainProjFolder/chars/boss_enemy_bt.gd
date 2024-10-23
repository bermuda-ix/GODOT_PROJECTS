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



var atk : int = 1
var atk_cmb : String = "attack_1"
var counter_speed : int = 1
var parried : bool = false
var full_combo : bool = false


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var knockback : Vector2 = Vector2.ZERO

func _ready():
	bt_player.blackboard.set_var("stunned", false)
	bt_player.blackboard.set_var("flee", false)
	#bt_player.blackboard.set_var("full_combo", false)

func _process(delta):
	var h = health.get_health()
	var s = stagger.get_stagger()
	
	hbsb.text=str("H: ",h," STG: ",s)
	

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	#move(-1, SPEED)
	bt_player.blackboard.set_var("full_combo", full_combo)
	var combo_state=bt_player.blackboard.get_var("full_combo")
	print(combo_state)
	move_and_slide()
	
	

func move(dir, speed):
	velocity.x = (dir * (speed * counter_speed)) + knockback.x
	
	knockback = lerp(knockback, Vector2.ZERO, 0.1)
	
	handle_animation(dir)
	

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
		bt_player.blackboard.set_var("flee", true)
		bt_player.blackboard.set_var("full_combo", true)
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
