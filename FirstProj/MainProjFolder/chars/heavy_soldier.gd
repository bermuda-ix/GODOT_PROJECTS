class_name HeavySoldier

extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const BALL_PROCETILE = preload("res://Component/ball_procetile.tscn")
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
@onready var gpu_particles_2d_2: GPUParticles2D = $AnimatedSprite2D/GPUParticles2D2
#On Screen
var is_on_screen : bool

var always_active : bool
#Defense
@onready var health: Health = $Health
@onready var stagger: Stagger = $Stagger
@onready var hurt_box: HurtBox = $HurtBox
@onready var hurt_box_collision: CollisionShape2D = $HurtBox/hurt_box_collision
@onready var hit_stop: HitStop = $HitStop
@onready var hit_stop_dur = 0.0
@onready var parry_box: ParryBox = $ParryBox
@onready var parry_box_collision: CollisionShape2D = $ParryBox/CollisionShape2D


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
@export var chase_speed : float = 40.0
@onready var launch_timer: Timer = $LaunchTimer


var current_speed : float = 0.0
var prev_speed : float = 00.0
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
var player_found : bool = true
#var player_colliding := false
var player : PlayerEntity = null
var distance
var player_state : LimboState

#States
@onready var state_machine: LimboHSM = $StateMachine
@onready var idle: Idle = $StateMachine/Idle
@onready var chasing: Chasing = $StateMachine/Chasing
@onready var jump: Jump = $StateMachine/Jump
@onready var attack: Attack = $StateMachine/Attack
@onready var melee_attack: LimboState = $StateMachine/MeleeAttack
@onready var shooting_states: LimboHSM = $StateMachine/ShootingStates
@onready var shooting: Shooting = $StateMachine/ShootingStates/Shooting
@onready var shooting_defense: LimboState = $StateMachine/ShootingStates/ShootingDefense
@onready var reload: LimboState = $StateMachine/ShootingStates/Reload
@onready var shoot_idle: LimboState = $StateMachine/ShootingStates/ShootIdle
@onready var defend_ally: BTState = $StateMachine/ShootingStates/DefendAlly
@onready var hit: Hit = $StateMachine/Hit
@onready var parry: Parry = $StateMachine/Parry
@onready var staggered: Staggered = $StateMachine/Staggered
@onready var dying: BTState = $StateMachine/Dying
@onready var death: Death = $StateMachine/Death
@onready var launch: Launch = $StateMachine/Launch



var state

#Combat States
@onready var combat_state_change_handler: CombatStateChangeHandler = $CombatStateChangeHandler
@onready var combat_state_machine: LimboHSM = $CombatStateMachine
@onready var ranged_mode: LimboState = $CombatStateMachine/ranged
@onready var melee_mode: LimboState = $CombatStateMachine/melee



#ATTACKS
@onready var melee_attack_manager: MeleeAttackManager = $MeleeAttackManager
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
@onready var bullet = BALL_PROCETILE
@onready var bullet_dir = Vector2.RIGHT
@onready var turret: Turret = $Turret
@onready var ammo_count

#DEATH
@export var drop : PackedScene
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
@onready var ally_vision_handler: AllyVisionHandler = $AllyVisionHandler
@onready var ally_vision_raycast: RayCast2D = $AllyVisionRaycast




#Debug var
var combat_state : String = "RANGED"
@onready var label: Label = $Label

	
func _ready():
	player = get_tree().get_first_node_in_group("player")
	#set_state(current_state, States.CHASE)
	ammo_count=turret.ammo_count
	bullet = BALL_PROCETILE
	animation_player.play("idle")
	state="guard"
	next=nav_agent.get_next_path_position()
	bt_player.blackboard.set_var("attack_mode", false)
	bt_player.blackboard.set_var("melee_mode", false)
	bt_player.blackboard.set_var("ranged_mode", true)
	bt_player.blackboard.set_var("within_range", false)
	bt_player.blackboard.set_var("staggered", false)
	Events.enemy_parried.connect(parry_success)
	#turret.setup(0.2)
	turret.shoot_timer.paused=true
	_init_state_machine()
	_init_combat_state_machine()
	_init_shooting_states()
	hurt_box.set_damage_mulitplyer(1)
	player_tracking.target_position=Vector2(vision_handler.vision_range,0)
	
	_init_group_link()
	if always_active:
		alerted()
	
	if health.health<=0:
		queue_free()


func _process(delta: float) -> void:
	if state_machine.get_active_state()==death:
		hb_collision.disabled=true
		return
	#if health.health<=0 and (state_machine.get_active_state()!=death and state_machine.get_active_state()!=dying):
		#print_debug(state_machine.get_active_state())
		#state_machine.dispatch(&"die")
	#even_order(group_link_order)
	knockback=clamp(knockback, Vector2(-400, -400), Vector2(400, 400) )
	knockback = lerp(knockback, Vector2.ZERO, 0.1)
	ammo_count=turret.ammo_count
	dir = to_local(next)
	vision_handler.handle_vision()
	distance = abs(global_position.x-player.global_position.x)
	force_chase()
	#if ammo_count<0:
		#print_debug("RELOAD")
		#animation_player.stop()
	if shooting_states.get_active_state()!=reload:
		defense_shoot()
	reload_gun()
	being_flipped()
	flip_ally_vision()
	if health.health<=0:
		if state_machine.get_active_state()!=dying and state_machine.get_active_state()!=death:
			state_machine.dispatch(&"die")
	
	#print_debug(current_speed)

func _physics_process(delta: float) -> void:
	if state_machine.get_active_state()==death:
		return
	
	if combat_state_machine.get_active_state()==ranged_mode or state_machine.get_active_state()==parry:
		if state_machine.get_active_state()!=chasing:
			if shooting_states.get_active_state()!=defend_ally:
				current_speed=0
	#
	if  state_machine.get_active_state()==hit or state_machine.get_active_state()==staggered:
		#hb_collison.disabled=true
		if launch_timer.time_left>0:
			global_position.y=lerpf(global_position.y, launch.launch_height, 0.1)
			velocity.y=0
		else:
			velocity.y += gravity * delta
		velocity.x=0
		move_and_slide()
		return
	elif state_machine.get_active_state()==dying:
		death_handler.dying()
	elif state_machine.get_active_state()==death :
		hb_collision.disabled=true
		return
	elif state_machine.get_active_state()==launch:
		global_position.y=lerpf(global_position.y, launch.launch_height, 0.1)
		velocity.y=0

	
	velocity.x = current_speed + knockback.x
	#print_debug(current_speed)
	#print_debug(velocity.x)
	move_and_slide()
	movement_handler.apply_gravity(delta)

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

func _init_state_machine():
	state_machine.initial_state=idle
	state_machine.initialize(self)
	state_machine.set_active(true)

	state_machine.add_transition(idle, attack, &"attack_mode")
	state_machine.add_transition(staggered, chasing, &"stagger_recover")
	state_machine.add_transition(attack, chasing, &"start_chase")
	state_machine.add_transition(shooting_states, chasing, &"start_chase")
	state_machine.add_transition(chasing, attack, &"start_attack")
	#state_machine.add_transition(shooting_states, attack, &"start_attack")
	state_machine.add_transition(attack, idle, &"idle_mode")
	state_machine.add_transition(chasing, jump, &"jump")
	state_machine.add_transition(jump, chasing, &"land")
	state_machine.add_transition(hit, attack, &"hit_recover")
	state_machine.add_transition(attack, parry, &"parry")
	state_machine.add_transition(chasing, parry, &"parry")
	state_machine.add_transition(shooting_states, parry, &"parry")
	state_machine.add_transition(parry, attack, parry.failure_event)
	state_machine.add_transition(parry, shooting_states, parry.success_event)
	state_machine.add_transition(attack, shooting_states, &"start_shoot")
	state_machine.add_transition(chasing, shooting_states, &"start_shoot")
	state_machine.add_transition(chasing, melee_attack, &"melee_attack")
	state_machine.add_transition(melee_attack, chasing, &"resume_chase")
	state_machine.add_transition(launch, idle, &"falling")
	
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

func _init_shooting_states():
	shooting_states.initial_state=shoot_idle
	#shooting_states.initialize(self)
	#shooting_states.set_active(false)
	
	shooting_states.add_transition(shoot_idle, shooting_defense, &"defensive_shoot")
	shooting_states.add_transition(shoot_idle, shooting, &"begin_shooting")
	
	shooting_states.add_transition(shooting, shooting_defense, &"defensive_shoot")
	shooting_states.add_transition(shooting_defense, shooting, &"offensive_shoot")
	shooting_states.add_transition(shooting_states.ANYSTATE, reload, &"reload")
	shooting_states.add_transition(reload, shooting, &"return_shooting")
	shooting_states.add_transition(shooting, defend_ally, &"begin_defend")
	shooting_states.add_transition(shooting_defense, defend_ally, &"begin_defend")
	shooting_states.add_transition(defend_ally, shooting_defense, defend_ally.success_event)
	
	
	
#Navigation
func makepath() -> void:
	nav_agent.target_position = player.global_position
	
func _on_navigation_timer_timeout() -> void:
	makepath()
	next_y=nav_agent.get_next_path_position().y
	next_x=nav_agent.get_next_path_position().x
	next=nav_agent.get_next_path_position()
	
#flip AllyVisionRaycast to keep point front
func flip_ally_vision():
	ally_vision_raycast.scale.x=animated_sprite_2d.scale.x

func defense_shoot() -> void:
	#print_debug(distance)
	if group_link_control==null:
		if distance>=50:
			shooting_states.dispatch(&"offensive_shoot")
			#print_debug("offensive")
		elif distance<50:
			shooting_states.dispatch(&"defensive_shoot")
			#print_debug("defensive")
	elif ally_vision_handler.ally_found:
		return
	else:
		if  group_enemy_manager.leader:
			shooting_states.dispatch(&"offensive_shoot")
			label.text=str("LEADER")
		else:
			shooting_states.dispatch(&"defensive_shoot")
			label.text=str("NO")
		#if group_enemy_manager.leader:
			#label.text=str("LEADER")
		#else:
			#label.text=str("NO")

func reload_gun() -> void:
	if turret.ammo_count<=0:
		shooting_states.dispatch(&"reload")

func target_lock():
	Events.unlock_from.emit()
	target_lock_node.target_lock()
	
func get_width() -> int:
	return abs(collision_shape_2d.get_shape().size.x * scale.x)
func get_height() -> int:
	return abs(collision_shape_2d.get_shape().size.y * scale.y)



func _on_state_machine_active_state_changed(current: LimboState, previous: LimboState) -> void:
	#print_debug(current)
	if current!=idle and current!=chasing:
		movement_handler.active=true
		shooting_states.dispatch(&"begin_shooting")
	elif current==shooting_states:
		assert(state_machine.get_previous_active_state()!=attack)
	#match current:
		#attack:
			#if combat_state_machine.get_active_state()==ranged_mode:
				#state_machine.dispatch(&"start_shoot")
		#chasing:
			#if combat_state_machine.get_active_state()==ranged_mode:
				#state_machine.dispatch(&"start_shoot")
		#shooting:
			#if combat_state_machine.get_active_state()==melee_mode:
				#state_machine.dispatch(&"start_chase")


func _on_combat_state_machine_active_state_changed(current: LimboState, previous: LimboState) -> void:
	if state_machine.get_active_state()==idle:
		return
	elif current==attack:
		if current==ranged_mode:
			state_machine.dispatch(&"start_shoot")
			
			movement_handler.active=false
			if shooting_states.get_active_state()!=defend_ally:
				current_speed=0
		elif current==melee_mode:
			movement_handler.active=true
			state_machine.dispatch(&"start_chase")
		

func _on_chasing_entered() -> void:
	animation_player.play("run")
	chase_speed=40



func _on_shooting_entered() -> void:
	animation_player.play("shoot")


func _on_shooting_defense_entered() -> void:
	animation_player.play("shoot_defense")


func _on_attack_entered() -> void:
	assert(state_machine.get_previous_active_state()!=shooting_states)
	#print_debug(state_machine.get_previous_active_state())
	if state_machine.get_active_state()!=idle:
		if combat_state_machine.get_active_state()==ranged_mode:
			state_machine.dispatch(&"start_shoot")
		elif combat_state_machine.get_active_state()==melee_mode:
			state_machine.dispatch(&"start_chase")
	else:
		return


func being_flipped() -> void:
	if player_state==player.flip_state or player.state_machine.get_previous_active_state()==player.flip_state:
		movement_handler.active=false
	else:
		movement_handler.active=true

func _on_shooting_states_active_state_changed(current: LimboState, previous: LimboState) -> void:
	pass
	#print_debug(current, ",", previous)


func _on_attack_range_body_entered(body: Node2D) -> void:
	if player.attacking:
		state_machine.dispatch(&"parry")
	else:
		state_machine.dispatch(&"melee_attack")

func parry_success() -> void:
	print_debug("parried")
	gpu_particles_2d.emitting=true
	gpu_particles_2d_2.emitting=true
	parry.blackboard.set_var("parry_success" , true)


func _on_parry_exited() -> void:
	print_debug("parry exit")


func _on_turret_shoot_bullet() -> void:
	shoot_handler.shoot_bullet()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="reload":
		shooting_states.dispatch(&"return_shooting")
	elif anim_name=="melee_attack":
		state_machine.dispatch(&"resume_chase")


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if state_machine.get_active_state()==parry and player_state!=player.flip_state:
		return
	if area.is_in_group("sp_atk_default"):
		if player_state==player.flip_state or player.state_machine.get_previous_active_state()==player.flip_state:
			Events.allied_enemy_hit.emit()
		print_debug("spc_hit")
		if animated_sprite_2d.flip_h:
			knockback.x=50
		else:
			knockback.x=-50
		stagger.stagger -= player.sp_atk_dmg

		
func _on_hurt_box_weakpoint_weakpoint_hit() -> void:
	if state_machine.get_active_state()==parry and player_state!=player.flip_state :
		return
	else:
		if player.state==player.States.FLIP or player.prev_state==player.States.FLIP:
			Events.allied_enemy_hit.emit()
		print_debug("spc_hit")
		if animated_sprite_2d.flip_h:
			knockback.x=50
		else:
			knockback.x=-50
		stagger.stagger -= player.sp_atk_dmg*3



func _on_stagger_staggered() -> void:
	stagger_timer.start(3)
	hb_collision.disabled=true
	current_speed=0
	velocity.x=0
	if (state_machine.get_active_state()!= dying and state_machine.get_active_state()!=death and state_machine.get_active_state()!=launch):
		if health.health>0:
			state_machine.dispatch(&"staggered")


func _on_hurt_box_received_damage(damage: int) -> void:
	if player.state==player.States.FLIP or player.prev_state==player.States.FLIP:
		Events.allied_enemy_hit.emit()
	
	#bt_player.restart()
	if state_machine.get_active_state()==death:
		return
	health.set_temporary_immortality(0.2)
	if damage<=health.health:
		parry_timer.start(0.5)
		if (state_machine.get_active_state()!=dying and state_machine.get_active_state()!=death):
			state_machine.dispatch(&"hit")
		hit_stop.hit_stop(0.05,0.25)
		#set_state(current_state, States.HIT)
		gpu_particles_2d.emitting=true
		
	else:
		print_debug("kill shot")


func _on_stagger_timer_timeout() -> void:
	if health.health>0:
		state_machine.dispatch(&"stagger_recover")
	else:
		state_machine.add_transition(state_machine.ANYSTATE, dying, &"die")


func _on_parry_timer_timeout() -> void:
	state_machine.dispatch(&"hit_recover")
	


func _on_health_health_depleted() -> void:
	parry_timer.stop()
	#hb_collision.disabled=true
	hb_collision.call_deferred("set_disabled", true)
	movement_handler.active=false
	animated_sprite_2d.scale.x = 1
	movement_handler.active=false
	knockback.x=250
	jump_handler.handle_jump(0.2)
	if linked_enemies!=null or not linked_enemies.is_empty():
		linked_enemies.remove_at(group_link_order)
	death_handler.death()


func _on_dying_entered() -> void:
	movement_handler.active=false
	hit_stop.hit_stop(0.1, 0.3)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if state_machine.get_active_state()==death:
		queue_free()

#DEBUG
#func leader():
	#if group_enemy_manager.leader:
		#label.text=str("LEADER")
	#else:
		#label.text=str("NO")
#
#func even_order(value: int):
	#if value==0 or value % 2 == 0:
		#label.text=str("EVEN")
	#else:
		#label.text=str("ODD")


func _on_shooting_states_entered() -> void:
	pass
	#print_debug("entering shooting")


func _on_vision_handler_player_sighted() -> void:
	if linked_enemies!=null:
		for i in range(linked_enemies.size()):
			linked_enemies[i].alerted()
				
			
func alerted() -> void :
	#print_debug("alerted!")
	vision_handler.always_on=true
	if on_screen.is_on_screen():
		state_machine.dispatch(&"attack_mode")
		bt_player.blackboard.set_var("attack_mode", true)
	else:
		bt_player.blackboard.set_var("attack_mode", false)
		state_machine.dispatch(&"start_chase")

func force_chase():
	is_on_screen=on_screen.is_on_screen()
	if not is_on_screen and vision_handler.always_on==true and state_machine.get_active_state()!=chasing and state_machine.get_active_state()!=melee_attack:
		state_machine.change_active_state(chasing)

func _on_parry_box_bullet_stopped() -> void:
	print_debug("shieled")


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	hit_stop.end_hit_stop()
	if vision_handler.player_found or vision_handler.always_on:
		state_machine.dispatch(&"attack_mode")
		bt_player.blackboard.set_var("attack_mode", true)
		
	if health.health<=0:
		queue_free()


func _on_ally_vision_handler_found_ally() -> void:
	shooting_states.dispatch(&"begin_defend")
	defend_ally.blackboard.set_var("ally_found", true)


func _on_ally_vision_handler_ally_gone() -> void:
	defend_ally.blackboard.set_var("ally_found", false)

func chase():
	#set_state(current_state, States.CHASE)
	state_machine.dispatch(&"start_chase")


func _on_melee_attack_entered() -> void:
	animation_player.play("melee_attack")


func _on_hit_box_clashed() -> void:
	animation_player.stop()
	hit_stop.hit_stop(0.1, 0.3)
	animation_player.play("melee_attack")
	print_debug("clashed!")


func _on_shield_area_entered(area: Area2D) -> void:
	health.set_temporary_immortality(0.5)


func _on_hit_box_clash_knock_back(_knockback : float) -> void:
	if player_right:
		knockback.x=_knockback
	else:
		knockback.x=_knockback


func _on_hit_box_clash_launch(_launch: float) -> void:
	state_machine.change_active_state(launch)


func _on_launch_entered() -> void:
	pass # Replace with function body.


func _on_launch_timer_timeout() -> void:
	state_machine.dispatch(&"falling")


func _on_hurt_box_launched() -> void:
	var _total_stagger_damage = player.clash_power.clash_power+player.hitbox.damage
	if _total_stagger_damage>=stagger.stagger:
		animation_player.play("launched")
		state_machine.change_active_state(launch)


func _on_death_entered() -> void:
	hb_collision.set_deferred("disabled", true)
	hurt_box_collision.set_deferred("disabled", true)
	set_collision_mask_value(15, true)
