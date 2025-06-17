class_name GuardEnemy
extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#Basic
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
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
@onready var locked_on : bool = false
var player_found : bool = true
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
@onready var shooting: LimboState = $LimboHSM/SHOOTING
@onready var dodge: LimboState = $LimboHSM/DODGE
@onready var hit: LimboState = $LimboHSM/HIT
@onready var staggered: LimboState = $LimboHSM/STAGGERED
var state

#Combat States
@onready var combat_state_change_handler: CombatStateChangeHandler = $CombatStateChangeHandler
@onready var combat_state_machine: LimboHSM = $CombatStateMachine
@onready var ranged_mode: LimboState = $CombatStateMachine/RANGED
@onready var melee_mode: LimboState = $CombatStateMachine/MELEE



#ATTACKS
@onready var melee_attack_manager: MeleeAttackManager = $MeleeAttackManager
@onready var dodge_manager: DodgeManager = $DodgeManager
@onready var attack_range: AttackRange = $AttackRange
@onready var hit_box: HitBox = $HitBox
@onready var hb_collision: CollisionShape2D = $HitBox/hb_collision
@onready var atk_chain : String = "_1"
@export var hitbox: HitBox
var parried : bool = false 
var attacking : bool = false

#Shooting
@onready var shoot_attack_manager: ShootAttackManager = $ShootAttackManager
@onready var shoot_handler: ShootHandler = $ShootHandler
@onready var bullet_dir = Vector2.RIGHT
@onready var turret: Turret = $Turret
@onready var ammo_count

#DEATH
@export var drop = preload("res://heart.tscn")
@onready var death_handler: DeathHandler = $DeathHandler
@export var death_time_scale: float = 1.0
@onready var norm_delta

#Grouping enemies
@onready var linked_enemies : Array[Node2D]
@export var group_link_control : EnemyGroup
@onready var group_link_order : int
@onready var is_leader : bool = false
@onready var is_even_order : bool = false
@onready var group_enemy_manager: GroupEnemyManager = $GroupEnemyManager

#Debug var
var combat_state : String = "RANGED"

func _ready():
	player = get_tree().get_first_node_in_group("player")
	#set_state(current_state, States.CHASE)
	animation_player.play("idle")
	state="guard"
	next=nav_agent.get_next_path_position()
	bt_player.blackboard.set_var("attack_mode", false)
	bt_player.blackboard.set_var("melee_mode", false)
	bt_player.blackboard.set_var("ranged_mode", true)
	bt_player.blackboard.set_var("within_range", false)
	bt_player.blackboard.set_var("staggered", false)
	dying.blackboard.set_var("hit_the_floor", false)
	turret.shoot_timer.paused=true
	_init_state_machine()
	_init_combat_state_machine()
	hurt_box.set_damage_mulitplyer(1)
	ammo_count=turret.ammo_count
	player_tracking.target_position=Vector2(vision_handler.vision_range,0)
	
	_init_group_link()
	
	
func _init_state_machine():
	state_machine.initial_state=idle
	state_machine.initialize(self)
	state_machine.set_active(true)

	state_machine.add_transition(idle, attack, &"attack_mode")
	state_machine.add_transition(staggered, chasing, &"stagger_recover")
	state_machine.add_transition(attack, chasing, &"start_chase")
	state_machine.add_transition(chasing, attack, &"start_attack")
	state_machine.add_transition(attack, idle, &"idle_mode")
	state_machine.add_transition(attack, jump, &"jump_attack")
	state_machine.add_transition(chasing, jump, &"jump")
	state_machine.add_transition(jump, chasing, &"land")
	state_machine.add_transition(jump, attack, &"land_attack")
	state_machine.add_transition(hit, attack, &"hit_recover")
	state_machine.add_transition(attack, dodge, &"dodge")
	state_machine.add_transition(dodge, attack, &"dodge_end")
	
	state_machine.add_transition(state_machine.ANYSTATE, hit, &"hit")
	state_machine.add_transition(state_machine.ANYSTATE, dying, &"die")
	state_machine.add_transition(dying, death, dying.success_event)
	state_machine.add_transition(state_machine.ANYSTATE, staggered, &"staggered")
	
func _init_combat_state_machine():
	combat_state_machine.initial_state=ranged_mode
	combat_state_machine.initialize(self)
	combat_state_machine.set_active(true)
	
	combat_state_machine.add_transition(ranged_mode, melee_mode, &"melee_mode")
	combat_state_machine.add_transition(melee_mode, ranged_mode, &"ranged_mode")

func _init_group_link():
	if group_link_control == null:
		print("no link")
		if linked_enemies.size()<=1:
			print("no link")
	else:
		linked_enemies=group_link_control.all_grouped_enemies
		for i in range(linked_enemies.size()):
			#print(linked_enemies[i].name, " linked")
			group_link_order=linked_enemies.find(self)
			print(group_link_order)
	group_enemy_manager.set_leader(group_link_order)
	group_enemy_manager.set_even_order(group_link_order)

func _process(_delta):
	ammo_count=turret.ammo_count
	bt_player.blackboard.set_var("ammo",ammo_count)
	dir = to_local(next)
	norm_delta=_delta
	
	
	if state_machine.get_active_state()==death or state_machine.get_active_state()==staggered or state_machine.get_active_state()==hit:
		hb_collision.disabled=true
		return
	elif state_machine.get_active_state()==idle:
		hb_collision.disabled=true

	handle_vision()
	if not attack_range.has_overlapping_bodies():
		bt_player.blackboard.set_var("within_range", false)
	#bt_player.blackboard.get_var("attack_mode"))
	attack_timer.one_shot=true
	
	
func _physics_process(delta):
	# standard delta
#	knockback return to zero
	knockback = lerp(knockback, Vector2.ZERO, 0.1)
#	stop movement when hit, staggered, or dead
	if  state_machine.get_active_state()==hit or state_machine.get_active_state()==staggered:
		#hb_collison.disabled=true
		velocity.y += gravity * delta
		velocity.x=0
		move_and_slide()
		return
	elif state_machine.get_active_state()==dying:
		move_and_slide()
		if is_on_floor() and not jump_timer.is_stopped():
			dying.blackboard.set_var("hit_the_floor", true)
		else:
			
			if death_timer.is_stopped():
				delta=delta
				velocity.y += gravity * delta
				animation_player.speed_scale=1
			else:
				delta*=lerpf(death_time_scale, 0, 0.2)
				animation_player.speed_scale=.5
				velocity.y += gravity * delta
				velocity.y=lerpf(velocity.y,0,0.2)
		velocity.x=knockback.x
	elif state_machine.get_active_state()==death :
		hb_collision.disabled=true
		return
	

	
	if state_machine.get_active_state()==staggered and parry_timer.time_left>0.0:
		state_machine.change_active_state(staggered)
		
	#handle_movement()
	if state_machine.get_active_state()==chasing:
		velocity.x = current_speed + knockback.x
		velocity.y += gravity * delta
	else:
		velocity.x= knockback.x
		
	#	apply gravity when in air
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

func makepath() -> void:
	nav_agent.target_position = player.global_position
	
func handle_vision():
	vision_handler.handle_vision()
		
func target_lock():
	Events.unlock_from.emit()
	target_lock_node.target_lock()
	locked_on=true
	
func chase():
	#set_state(current_state, States.CHASE)
	state_machine.change_active_state(chasing)
	
func get_width() -> int:
	return collision_shape_2d.get_shape().radius
func get_height() -> int:
	return collision_shape_2d.get_shape().radius+10



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
		"dodge":
			state_machine.dispatch(&"dodge_end")

func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and state_machine.get_active_state()!=staggered:
		bt_player.blackboard.set_var("within_range", true)
		#set_state(current_state, States.ATTACK)
		state_machine.dispatch(&"start_attack")

func _on_attack_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and not animation_player.is_playing() and state_machine.get_active_state()!=staggered:
		bt_player.blackboard.set_var("within_range", false)
		#set_state(current_state, States.CHASE)
		state_machine.dispatch(&"start_chase")

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("sp_atk_default"):
		if player.state==player.States.FLIP or player.prev_state==player.States.FLIP:
			Events.allied_enemy_hit.emit()
		print("spc_hit")
		if animated_sprite_2d.flip_h:
			knockback.x=50
		else:
			knockback.x=-50
		stagger.stagger -= player.sp_atk_dmg

func _on_navigation_timer_timeout() -> void:
	makepath()
	next_y=nav_agent.get_next_path_position().y
	next_x=nav_agent.get_next_path_position().x
	next=nav_agent.get_next_path_position()

func _on_stagger_staggered() -> void:
	bt_player.restart()
	parry_timer.start(3)
	hb_collision.disabled=true
	print("staggered")
	state_machine.dispatch(&"staggered")

func _on_parry_timer_timeout() -> void:
	if state_machine.get_active_state()==staggered:
		state_machine.dispatch(&"stagger_recover")
	elif state_machine.get_active_state()==hit:
		state_machine.dispatch(&"hit_recover")
	movement_handler.active=true
	hurt_box.set_damage_mulitplyer(1)


func _on_hurt_box_received_damage(damage: int) -> void:
	
	if player.state==player.States.FLIP or player.prev_state==player.States.FLIP:
		Events.allied_enemy_hit.emit()
	
	bt_player.restart()
	if state_machine.get_active_state()==death:
		return
	health.set_temporary_immortality(0.2)
	if damage<health.health:
		if state_machine.get_active_state()!=dying or state_machine.get_active_date()!=death:
			hit_stop.hit_stop(0.05,0.25)
		parry_timer.start(0.5)
		state_machine.dispatch(&"hit")
		gpu_particles_2d.restart()
		gpu_particles_2d.emitting=true
		
	else:
		
		print("kill shot")

func _on_health_health_depleted() -> void:
	parry_timer.stop()
	hb_collision.disabled=true
	animated_sprite_2d.scale.x = 1
	movement_handler.active=false
	knockback.x=250
	jump_handler.handle_jump(0.5)
	death_timer.start()
	if linked_enemies!=null:
		linked_enemies.remove_at(group_link_order)
	death_handler.death()

func _on_attack_timer_timeout() -> void:
	if state_machine.get_active_state()==staggered:
		return
	if bt_player.blackboard.get_var("within_range"):
		state_machine.dispatch(&"start_attack")
	else:
		state_machine.dispatch(&"start_chase")

func _on_turret_shoot_bullet() -> void:
	shoot_handler.shoot_bullet()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if state_machine.get_active_state()==death:
		queue_free()

func _on_limbo_hsm_active_state_changed(current: LimboState, previous: LimboState) -> void:
	if current==jump:
		if previous==attack:
			print("down attack")

func _on_hit_box_area_entered(area: Area2D) -> void:
	
	if state_machine.get_active_state()!=dying or state_machine.get_active_state()!=death:
		hit_stop.hit_stop(0.05,0.1)


func _on_vision_handler_player_sighted() -> void:
	if linked_enemies!=null:
		for i in range(linked_enemies.size()):
			linked_enemies[i].alerted()
			
func alerted() -> void :
	print("alerted!")
	vision_handler.always_on=true
	state_machine.dispatch(&"attack_mode")
