class_name GuardEnemy
extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#Basic
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var always_active : bool
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var is_on_screen : bool = false

#Animation Player
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var vfx_player: AnimationPlayer = $AnimationPlayer/VFXPlayer
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
@onready var knocked_back = false

#Timers
@onready var navigation_timer: Timer = $NavigationTimer
@onready var jump_timer: Timer = $JumpTimer
@onready var parry_timer: Timer = $ParryTimer
@onready var chase_timer: Timer = $ChaseTimer
@onready var death_timer: Timer = $DeathTimer
@onready var dodge_timer: Timer = $DodgeTimer
@onready var attack_timer: Timer = $AttackTimer
@onready var stagger_timer: Timer = $StaggerTimer
@onready var launch_timer: Timer = $LaunchTimer
@onready var clash_timer: Timer = $ClashTimer


#movement
@onready var movement_handler: MovementHandler = $MovementHandler
@onready var jump_handler: JumpHandler = $JumpHandler
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@export var jump_speed : float = 120.0
@export var chase_speed : float = 80.0
#@export var knockback_distance : float = 500

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
@onready var launch: Launch = $LimboHSM/LAUNCHED
@onready var falling: LimboState = $LimboHSM/FALLING
@onready var landed: LimboState = $LimboHSM/Landed
@onready var clashed: Clashed = $LimboHSM/Clashed



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
@onready var counter_flag : bool = false

#Shooting
@onready var shoot_attack_manager: ShootAttackManager = $ShootAttackManager
@onready var shoot_handler: ShootHandler = $ShootHandler
@onready var bullet_dir = Vector2.RIGHT
@onready var turret: Turret = $Turret
@onready var ammo_count

#DEATH
@export var drop : PackedScene
@onready var death_handler: DeathHandler = $DeathHandler
@export var death_time_scale: float = 1.0
@onready var norm_delta
@export var death_knockback := 100.0
@export var death_launch := -30

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
	bt_player.blackboard.set_var("atk_counter", false)
	bt_player.blackboard.set_var("atk_1", true)
	bt_player.blackboard.set_var("ranged_mode", true)
	bt_player.blackboard.set_var("within_range", false)
	bt_player.blackboard.set_var("staggered", false)
	bt_player.blackboard.set_var("launched", false)
	bt_player.blackboard.set_var("falling", false)
	bt_player.blackboard.set_var("dodge", false)
	dying.blackboard.set_var("hit_the_floor", false)
	turret.shoot_timer.paused=true
	_init_state_machine()
	_init_combat_state_machine()
	hurt_box.set_damage_mulitplyer(1)
	ammo_count=turret.ammo_count
	player_tracking.target_position=Vector2(vision_handler.vision_range,0)
	_init_group_link()
	if health.health<=0:
		queue_free()
	if always_active:
		state_machine.remove_transition(attack, &"idle_mode")
		alerted()
		#chase()
	
	
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
	state_machine.add_transition(attack, clashed, &"clashed")
	state_machine.add_transition(clashed, attack, &"counter_attack")
	state_machine.add_transition(clashed, dodge, &"dodge_back")
	state_machine.add_transition(launch, hit, &"midair_hit")
	state_machine.add_transition(launch, falling, &"falling")
	state_machine.add_transition(hit, falling, &"falling")
	state_machine.add_transition(falling, landed, &"landed")
	state_machine.add_transition(landed, attack, &"resume_attack")
	state_machine.add_transition(landed, staggered, &"stagger_land")
	
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
		print_debug("no link")
		if linked_enemies.size()<=1:
			print_debug("no link")
	else:
		linked_enemies=group_link_control.all_grouped_enemies
		for i in range(linked_enemies.size()):
			#print_debug(linked_enemies[i].name, " linked")
			group_link_order=linked_enemies.find(self)
			print_debug(group_link_order)
	group_enemy_manager.set_leader(group_link_order)
	group_enemy_manager.set_even_order(group_link_order)

func _process(_delta):
	is_on_screen=visible_on_screen_notifier_2d.is_on_screen()
	ammo_count=turret.ammo_count
	bt_player.blackboard.set_var("ammo",ammo_count)
	dir = to_local(next)
	norm_delta=_delta
	vision_handler.get_player_relative_loc()
	
	if not is_on_screen and vision_handler.always_on==true and state_machine.get_active_state()!=chasing:
		state_machine.change_active_state(chasing)
	
	if state_machine.get_active_state()==death or state_machine.get_active_state()==staggered or state_machine.get_active_state()==hit:
		hb_collision.set_deferred("disabled", true)
		return
	elif state_machine.get_active_state()==idle:
		hb_collision.set_deferred("disabled", true)
	elif (state_machine.get_active_state()!=death or state_machine.get_active_state()==dying) and health.health<=0:
		state_machine.dispatch(&"die")
	
			
	handle_vision()
	if not attack_range.has_overlapping_bodies() and state_machine.get_active_state()==chasing:
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
		hb_collision.set_deferred("disabled", true)
		return
	
	elif state_machine.get_active_state()!=launch:
		velocity.y += gravity * delta
	else:
		#global_position.y=lerpf(global_position.y, launch.launch_height, 0.1)
		velocity.y=0

	
	if state_machine.get_active_state()==staggered and parry_timer.time_left>0.0:
		state_machine.change_active_state(staggered)
		
	#handle_movement()
	if state_machine.get_active_state()==chasing:
		velocity.x = current_speed + knockback.x
		velocity.y += gravity * delta
	else:
		if state_machine.get_active_state()!=attack and state_machine.get_active_state()!=launch and state_machine.get_active_state()!=dodge:
			velocity.x= knockback.x
		
	#	apply gravity when in air
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

func makepath() -> void:
	nav_agent.target_position = player.global_position
	
func path_valid() -> bool:
	return nav_agent.is_target_reachable()
	
func handle_vision():
	vision_handler.handle_vision()
		
func target_lock():
	Events.unlock_from.emit()
	target_lock_node.target_lock()
	locked_on=true
	
func chase():
	#set_state(current_state, States.CHASE)
	if state_machine.get_active_state()!=chasing:
		state_machine.change_active_state(chasing)
	
func get_width() -> int:
	return collision_shape_2d.get_shape().radius
func get_height() -> int:
	return collision_shape_2d.get_shape().radius+10


func dodge_counter() -> void:
	var _dodge_chance = randi_range(0,1)
	if _dodge_chance==0:
		dodge.dodge_anim="dodge_forward"
		dodge.dodge_setup(150, 0)
	else:
		dodge.dodge_anim="dodge_back"
		dodge.dodge_setup(-400, 0)
	bt_player.blackboard.set_var("dodge", true)
	state_machine.dispatch(&"dodge_back")

func dodge_end() -> void:
	bt_player.blackboard.set_var("dodge", false)
	state_machine.dispatch(&"dodge_end")
	bt_player.blackboard.set_var("within_range", true)
	set_collision_layer_value(15, true)
	bt_player.restart()
	melee_attack_manager.atk_resume_helper()
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	
	if anim_name.substr(0, 3)=="atk":
		if anim_name=="atk_counter":
			bt_player.blackboard.set_var("atk_counter", false)
			melee_attack_manager.reset_combo()
		else:
			melee_attack_manager.next_combo()
		bt_player.blackboard.set_var(melee_attack_manager.get_combo(), true)
		attack_timer.start(0.3)
		bt_player.active=true
		attacking=false
		
		
	elif anim_name=="clashed":
		bt_player.blackboard.set_var("staggered", false)
		dodge_counter()
		
	elif anim_name==dodge.dodge_anim:
		dodge_end()
	
func _on_vfx_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="staggered_entered":
		vfx_player.play("staggered")
	elif anim_name=="clased":
		state_machine.dispatch(&"counter_attack")
	

	
	#match anim_name:
		#"atk_1":
			#bt_player.blackboard.set_var("atk_2", true)
			#atk_chain="_2"
			#attack_timer.start(0.3)
			#bt_player.active=true
			#attacking=false
		#"atk_2":
			#bt_player.blackboard.set_var("atk_3", true)
			#atk_chain="_3"
			#attack_timer.start(0.3)
			#bt_player.active=true
			#attacking=false
		#"atk_3":
			#bt_player.blackboard.set_var("atk_1", true)
			#atk_chain="_1"
			#attack_timer.start(0.3)
			#bt_player.active=true
			#attacking=false
		#"atk_counter":
			#bt_player.blackboard.set_var("atk_counter", false)
			#atk_chain="_1"
			#bt_player.blackboard.set_var("atk_1", true)
			#bt_player.active=true
			#attacking=false

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	if anim_name.substr(0, 3)=="atk":
		bt_player.active=false
		attacking=true
		hb_collision.set_deferred("disabled", false)
	elif anim_name== "dodge":
		state_machine.dispatch(&"dodge_end")


func set_attack_trigger(_value : String) -> void:
	pass
	var _chain := "atk"+atk_chain
	bt_player.blackboard.set_var(_chain, true)

func _on_attack_range_body_entered(body: Node2D) -> void:
	if attacking==true:
		return
	elif body.is_in_group("player") and state_machine.get_active_state()!=staggered:
		bt_player.blackboard.set_var("within_range", true)
		#set_state(current_state, States.ATTACK)
		state_machine.dispatch(&"start_attack")

func _on_attack_range_body_exited(body: Node2D) -> void:
	if attacking==true:
		return
	elif body.is_in_group("player") and not animation_player.is_playing() and state_machine.get_active_state()!=staggered:
		bt_player.blackboard.set_var("within_range", false)
		#set_state(current_state, States.CHASE)
		state_machine.dispatch(&"start_chase")

func _on_hurt_box_area_entered(area: Area2D) -> void:
	death_knockback=100.0
	death_launch=-30.0
	if area.is_in_group("sp_atk_default"):
		if player.state==player.States.FLIP or player.prev_state==player.States.FLIP:
			Events.allied_enemy_hit.emit()
		print_debug("spc_hit")
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
	parry_timer.start(5)
	hb_collision.set_deferred("disabled", true)
	if state_machine.get_active_state()!=launch:
		bt_player.blackboard.set_var("staggered", true)
		state_machine.change_active_state(staggered)
	Events.camera_shake.emit(2,20)

func _on_parry_timer_timeout() -> void:
	if state_machine.get_active_state()==staggered:
		state_machine.dispatch(&"stagger_recover")
		bt_player.blackboard.set_var("staggered", false)
	elif state_machine.get_active_state()==hit:
		state_machine.dispatch(&"hit_recover")
	movement_handler.active=true
	hurt_box.set_damage_mulitplyer(1)


func _on_hurt_box_received_damage(damage: int) -> void:
	#if state_machine.get_active_state()==staggered:
		#return
	
	if player.state==player.States.FLIP or player.prev_state==player.States.FLIP:
		Events.allied_enemy_hit.emit()
	
	bt_player.restart()
	if state_machine.get_active_state()==death:
		return
	health.set_temporary_immortality(0.2)
	if damage<health.health:
		if state_machine.get_active_state()!=dying or state_machine.get_active_date()!=death:
			hit_stop.hit_stop(0.05,0.25)
		
		if state_machine.get_active_state()!=staggered:
			parry_timer.start(0.1)
			#hit_stop.hit_stop(0.01,0.01)
			Events.camera_shake.emit(2,20)
			state_machine.dispatch(&"hit")
		else:
			animation_player.play("hit")
			#hit_stop.hit_stop(0.01,0.01)
			AudioStreamManager.play(SoundFx.SOCAPEX_NEW_HITS_2)
		gpu_particles_2d.restart()
		gpu_particles_2d.emitting=true
		melee_attack_manager.atk_resume_helper()
		bt_player.active=true
	else:
		
		print_debug("kill shot")

func _on_health_health_depleted() -> void:
	parry_timer.stop()
	#hb_collision.disabled=true
	hb_collision.call_deferred("set_disabled", true)
	animated_sprite_2d.scale.x = 1
	movement_handler.active=false
	if player_right:
		knockback.x=-250
	else:
		knockback.x=250
	jump_handler.handle_jump(0.5)
	death_timer.start()
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
	if state_machine.get_active_state()==death or state_machine.get_active_state()==dying:
		queue_free()
	else:
		if vision_handler.player_found or vision_handler.always_on:
			state_machine.dispatch(&"start_chase")
			bt_player.blackboard.set_var("attack_mode", false)
			chase()

func _on_limbo_hsm_active_state_changed(current: LimboState, previous: LimboState) -> void:
	if current==jump:
		if previous==attack:
			print_debug("down attack")
	if not visible_on_screen_notifier_2d.is_on_screen():
		if current==attack:
			push_error("ERROR: State changed")
	#print_debug(current)

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		print_debug("clash success")
	if state_machine.get_active_state()!=dying or state_machine.get_active_state()!=death:
		hit_stop.hit_stop(0.05,0.1)


func _on_vision_handler_player_sighted() -> void:
	bt_player.blackboard.set_var("attack_mode", true)
	if linked_enemies!=null:
		for i in range(linked_enemies.size()):
			linked_enemies[i].alerted()
			
func alerted() -> void :
	print_debug("alerted!")
	vision_handler.always_on=true
	if not path_valid():
		return
	else:
		if visible_on_screen_notifier_2d.is_on_screen():
			state_machine.dispatch(&"attack_mode")
			bt_player.blackboard.set_var("attack_mode", true)
		else:
			bt_player.blackboard.set_var("attack_mode", false)
			state_machine.dispatch(&"start_chase")
		


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	if vision_handler.player_found or vision_handler.always_on:
		state_machine.dispatch(&"attack_mode")
		bt_player.blackboard.set_var("attack_mode", true)


func _on_launch_timer_timeout() -> void:
	pass # Replace with function body.
	state_machine.dispatch(&"falling")
	###Falling to idle
	


func _on_falling_entered() -> void:
	animation_player.play("falling")
	bt_player.blackboard.set_var("launched", false)
	bt_player.blackboard.set_var("falling", true)



func _on_launched_entered() -> void:
	if stagger.stagger >0:
		hit_stop.hit_stop(0.2, 0.5)
		landed.landed_type="landed_recover"
		if player_right:
			velocity.x=-750
		else:
			velocity.x=750
			
		launch.launch_height=launch.launch_height/2
		animation_player.play("jump_recover")
		counter_flag=true
	else:
		landed.landed_type="landed"
		animation_player.play("launched")
	bt_player.blackboard.set_var("launched", true)


func _on_hurt_box_launched(launch_strength: float) -> void:
	launch.launch_strength=launch_strength
	state_machine.change_active_state(launch)


func _on_hurt_box_knockback(_launch_strength : float, _knock_back_strength : float, _impact_dir_right : bool) -> void:
	player.clash_up.emit()
	vfx_player.play("knocked_back")
	hit_stop.hit_stop(0.01, 0.1)
	var _total_stagger_damage = player.clash_power.clash_power+player.hitbox.damage
	if _total_stagger_damage>=stagger.stagger:
		if player_right:
			launch.knock_back_strength = _knock_back_strength
		else:
			launch.knock_back_strength = -_knock_back_strength
		launch.launch_strength=_launch_strength
		launch.air_time=1.0
		state_machine.change_active_state(launch)
	


func _on_hurt_box_body_entered(body: Node2D) -> void:
	death_knockback=10.0
	death_launch=0
	#if "knocked_back" in body:
		#if body.knocked_back == true:
			#knockback.x=body.velocity.x/2
			#hit_stop.hit_stop(0.01, 0.1)
			#stagger.staggered.emit()
			#Events.camera_shake.emit(2,20)


func _on_hit_entered() -> void:
	bt_player.blackboard.set_var("hit", true)

func _on_hit_exited() -> void:
	bt_player.blackboard.set_var("hit", false)


func _on_hit_box_clashed() -> void:
	bt_player.blackboard.set_var("staggered", true)
	print_debug("clashed!")
	stagger.stagger-=1
	attacking=false
	state_machine.dispatch(&"clashed")
	
	


func _on_hit_box_clash_knock_back(_launch : float, _knockback : float, _impact_dir_right: bool) -> void:
	knocked_back=true
	vfx_player.play("knocked_back")
	var _total_stagger_damage = player.clash_power.clash_power+player.hitbox.damage
	if _total_stagger_damage>=stagger.stagger:
		if player_right:
			launch.knock_back_strength = -_knockback
		else:
			launch.knock_back_strength = _knockback
	else:
		if player_right:
			launch.knock_back_strength = -_knockback/2
		else:
			launch.knock_back_strength = _knockback/2
	launch.launch_strength=_launch
	state_machine.change_active_state(launch)
	stagger.stagger-=_total_stagger_damage


func _on_hit_box_clash_launch(_launch: float) -> void:
	state_machine.change_active_state(launch)


func _on_falling_updated(delta: float) -> void:
	pass
	#if is_on_floor():
		#
		#state_machine.dispatch(&"landed")

func _on_landed_landed() -> void:
	if stagger.stagger<=0:
		state_machine.dispatch(&"stagger_land")
	else:
		bt_player.blackboard.set_var("falling", false)
		if counter_flag:
			atk_chain="_counter"
			bt_player.blackboard.set_var("atk_counter", true)
			bt_player.blackboard.set_var("melee_mode", true)
			bt_player.blackboard.set_var("within_range", true)
			#state_machine.dispatch(&"resume_attack")
			melee_attack_manager.melee_counter()
			counter_flag=false
		else:
			state_machine.dispatch(&"resume_attack")

func launch_recover() -> void:
	launch_timer.stop()
	state_machine.dispatch(&"falling")


func _on_animation_player_animation_changed(old_name: StringName, new_name: StringName) -> void:
	if old_name=="atk_counter":
		print_debug("w0t")
	if new_name=="atk_counter":
		print_debug("starting")


func _on_dodge_entered() -> void:
	movement_handler.active=false


func _on_dying_entered() -> void:
	knocked_back=true
	if player_right:
		knockback.x=-death_knockback
	else:
		knockback.x=death_knockback
	knockback.y=death_launch


func _on_chasing_entered() -> void:
	attacking=false
	bt_player.blackboard.set_var("atk_1", true)
	

func _on_attack_entered() -> void:
	hb_collision.set_deferred("disabled", false)


func _on_clashed_entered() -> void:
	clash_timer.start(0.1)
	#hit_stop.hit_stop(0.01, 0.2)
	#var _current_anim = animation_player.current_animation
	#animation_player.play_section_with_markers(_current_anim, "clashed")
	#animation_player.pause()
	#clash_timer.start(0.2)


func _on_clash_timer_timeout() -> void:
	print_debug(state_machine.get_active_state())
	bt_player.blackboard.set_var("staggered", false)
	state_machine.dispatch(&"counter_attack")
	melee_attack_manager.melee_attack()


func _on_hit_stop_hit_stop_finished() -> void:
	vfx_player.speed_scale=1
