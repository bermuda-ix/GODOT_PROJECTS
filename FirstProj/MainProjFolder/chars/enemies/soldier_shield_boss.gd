extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -400.0

const vision_active = false
const vision_stay_on = true
const vision_always_on = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")



### Sprites
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var vfx_sprite: AnimatedSprite2D = $AnimatedSprite2D/VFXSprite
@onready var hit_fx_sprite: AnimatedSprite2D = $AnimatedSprite2D/HitFXSprite
@onready var shield_sprite: AnimatedSprite2D = $AnimatedSprite2D/ShieldSprite
@onready var shield: Area2D = $AnimatedSprite2D/ShieldSprite/Shield
@onready var shield_collision: CollisionShape2D = $AnimatedSprite2D/ShieldSprite/Shield/ShieldCollision
@onready var gun: AnimatedSprite2D = $AnimatedSprite2D/Gun
@onready var attack_vfx: AnimatedSprite2D = $AnimatedSprite2D/AttackVFX

### Collisions
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hurt_box: HurtBox = $HurtBox
@onready var hurt_box_collision: CollisionShape2D = $HurtBox/HurtBoxCollision
@onready var hit_box: HitBox = $HitBox
@onready var hit_box_collision: CollisionShape2D = $HitBox/HitBoxCollision
@onready var attack_range: AttackRange = $AttackRange
@onready var bullet_detection: BulletDetection = $BulletDetection

### Navigation
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var next_nav_point : Vector2 = Vector2.ZERO
@onready var dir_to_next : Vector2 = Vector2.ZERO
@onready var distance_to_next := 0.0

### On Screen checks
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var is_on_screen : bool

### Animation Players
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var vfx_player: AnimationPlayer = $AnimationPlayer/VFXPlayer
@onready var hit_fx_player: AnimationPlayer = $AnimationPlayer/HitFXPlayer

### Basic Stats
@onready var health: Health = $Health
@onready var stagger: Stagger = $Stagger
@onready var clash_power: ClashPower = $ClashPower

### Timers
@onready var navigation_timer: Timer = $NavigationTimer
@onready var jump_timer: Timer = $JumpTimer
@onready var parry_timer: Timer = $ParryTimer
@onready var chase_timer: Timer = $ChaseTimer
@onready var death_timer: Timer = $DeathTimer
@onready var dodge_timer: Timer = $DodgeTimer
@onready var attack_timer: Timer = $AttackTimer
@onready var stun_timer: Timer = $StunTimer
@onready var stagger_timer: Timer = $StaggerTimer
@onready var clash_timer: Timer = $ClashTimer
@onready var counter_timer: Timer = $CounterTimer
@onready var launch_timer: Timer = $LaunchTimer
@onready var counter_attack_timer: Timer = $CounterAttackTimer

### Movement Handlers
@onready var movement_handler: MovementHandler = $MovementHandler
@onready var jump_handler: JumpHandler = $JumpHandler
@onready var dodge_manager: DodgeManager = $DodgeManager
@onready var teleport_handler: TeleportHandler = $TeleportHandler
@onready var teleport_raycast_helper: RayCast2D = $TeleportRaycastHelper
@onready var current_speed : float = 40.0
@onready var prev_speed : float = 40.0
@onready var acceleration : float = 800.0
@onready var jump_velocity = JUMP_VELOCITY
@onready var knockback : Vector2 = Vector2.ZERO
@onready var spawn_loc : Vector2

### Vision and tracking
@onready var player_tracker: ShapeCast2D = $PlayerTracker
@onready var player_tracking_handler: PlayerTrackingHandler = $PlayerTrackingHandler
@onready var vision_handler: VisionHandler = $VisionHandler
@onready var get_player_info_handler: GetPlayerInfoHandler = $GetPlayerInfoHandler
@onready var player_found : bool = true
@onready var player : PlayerEntity = null
@onready var player_behind : bool = false
@onready var player_right : bool = false
@onready var player_state : LimboState = null


### Attack Handlers
@onready var shoot_handler: ShootHandler = $ShootHandler
@onready var ammo_count
@onready var melee_attack_manager: MeleeAttackManager = $MeleeAttackManager
@onready var shoot_attack_manager: ShootAttackManager = $ShootAttackManager
@onready var counter_attack_handler: CounterAttackHandler = $CounterAttackHandler
@onready var parried : bool = false 
@onready var attacking : bool = false :set = set_attacking
@onready var attack_missed : bool = false
@onready var dash_attacking : bool = false
@onready var turret: Turret = $Turret
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $Turret/AudioStreamPlayer2D


@onready var target_lock_node: TargetLock = $TargetLock
@onready var locked_on := false

### Death
@onready var death_handler: DeathHandler = $DeathHandler

### Hitstop
@onready var hit_stop: HitStop = $HitStop
@onready var hit_stop_dur = 0.1

### QTE Handler
@onready var qte_handler: QTEHandler = $QTEHandler

### Cutscene Handler
@onready var cutscene_handler: CutsceneHandler = $CutsceneHandler
@onready var speed: Label = $Speed
@export var death_cutscene : bool = false

### Boss UI
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var boss_ui: Control = $CanvasLayer/BossUI

### Phases Handler
@onready var changing_phase := false
@onready var phases_handler: PhasesHandler = $PhasesHandler
@onready var phases: LimboHSM = $Phases
@onready var phase_1: LimboState = $Phases/Phase1
@onready var phase_2: LimboState = $Phases/Phase2

### State Machine
@onready var state_machine: LimboHSM = $LimboHSM
@onready var idle: Idle = $LimboHSM/IDLE
@onready var chasing: Chasing = $LimboHSM/CHASING
@onready var jump: Jump = $LimboHSM/JUMP
@onready var death: Death = $LimboHSM/DEATH
@onready var attack: Attack = $LimboHSM/ATTACK
@onready var teleport_and_shoot: BTState = $LimboHSM/TeleportAndShoot
@onready var teleport_and_hit: BTState = $LimboHSM/TeleportAndHit
@onready var dodge: Dodge = $LimboHSM/DODGE
@onready var block: LimboState = $LimboHSM/BLOCK
@onready var hit: Hit = $LimboHSM/HIT
@onready var staggered: Staggered = $LimboHSM/STAGGERED
@onready var dying: BTState = $LimboHSM/DYING
@onready var phasetransition: BTState = $LimboHSM/PHASETRANSITION
@onready var launch: Launch = $LimboHSM/Launch
@onready var falling: Falling = $LimboHSM/Falling
@onready var land: Land = $LimboHSM/Land
@onready var clashed_state: ClashedState = $LimboHSM/ClashedState
@onready var clash_start: LimboState = $LimboHSM/ClashedState/ClashStart
@onready var clash_counter: ClashCounter = $LimboHSM/ClashedState/ClashCounter
@onready var clash_fail: ClashFail = $LimboHSM/ClashedState/ClashFail
@onready var clash_heavy_counter: ClashHeavyCounterState = $LimboHSM/ClashedState/ClashHeavyCounter
@onready var clash_dodge: ClashDodge = $LimboHSM/ClashedState/ClashDodge

### Combat State
@onready var combat_state_machine: LimboHSM = $CombatStateMachine
@onready var ranged_state: ranged = $CombatStateMachine/RANGED
@onready var melee_state: melee = $CombatStateMachine/MELEE

@export_category("Boss Variables")
@export var lvl_boss : bool
@export var death_flag_name : String

@export_category("DEBUG")

### Signals
signal boss_reloaded



##If spawned on event
@export var spawned := true



### Setters
func set_attacking(_value: bool) -> void:
	attacking=_value
	
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	ammo_count=turret.ammo_count
	animation_player.play("idle")
	melee_attack_manager.combo_max=3
	next_nav_point=nav_agent.get_next_path_position()
	_init_state_machine()
	_init_boss_ui()
	_init_phase_state_machine()

func _init_state_machine():
	state_machine.initial_state=idle
	state_machine.initialize(self)
	state_machine.set_active(true)
	
	state_machine.add_transition(idle, attack, &"start_attack")
	state_machine.add_transition(idle, chasing, &"start_chase")
	
	state_machine.add_transition(chasing, attack, &"start_attack")
	state_machine.add_transition(chasing, block, &"block")
	state_machine.add_transition(chasing, dodge, &"dodge")
	state_machine.add_transition(chasing, jump, &"jump")
	state_machine.add_transition(chasing, staggered, &"staggered")
	state_machine.add_transition(chasing, launch, &"launch")
	state_machine.add_transition(chasing, clashed_state, &"clashed")
	
	state_machine.add_transition(attack, chasing, &"start_chase")
	state_machine.add_transition(attack, jump, &"jump")
	state_machine.add_transition(attack, block, &"block")
	state_machine.add_transition(attack, dodge, &"dodge")
	state_machine.add_transition(attack, staggered, &"staggered")
	state_machine.add_transition(attack, launch, &"launch")
	state_machine.add_transition(attack, clashed_state, &"clashed")
	
	state_machine.add_transition(jump, falling, &"falling")
	state_machine.add_transition(launch, falling, &"falling")
	state_machine.add_transition(falling, land, &"landed")
	state_machine.add_transition(jump, land, &"landed")
	state_machine.add_transition(jump, staggered, &"staggered")
	state_machine.add_transition(jump, launch, &"launch")
	state_machine.add_transition(falling, staggered, &"staggered")
	
	state_machine.add_transition(clashed_state, staggered, &"staggered")
	state_machine.add_transition(clashed_state, attack, &"counter_attack")
	
	state_machine.add_transition(state_machine.ANYSTATE, phasetransition, &"begin_next_phase")
	
	
	
func _init_phase_state_machine():
	phases.initial_state=phase_1
	phases.initialize(self)
	phases.set_active(true)
	
	phases.add_transition(phase_1, phase_2, &"next_phase")

func _init_boss_ui() -> void:
	boss_ui.set_max_boss_health(health.max_health)
	boss_ui.set_boss_health(health.health)

func _process(delta: float) -> void:
	if not cutscene_handler.actor_control_active or not qte_handler.actor_control_active:
		return
	dir_to_next = to_local(next_nav_point)
	
	if state_machine.get_active_state()==death or state_machine.get_active_state()==staggered or state_machine.get_active_state()==hit:
		hit_box_collision.disabled=true
		return
	elif state_machine.get_active_state()==idle:
		hit_box_collision.disabled=true
	
	is_on_screen=visible_on_screen_notifier_2d.is_on_screen()
	
	
func _physics_process(delta: float) -> void:
	if not cutscene_handler.actor_control_active or not qte_handler.actor_control_active:
		apply_gravity(delta)
		#cutscene_acceleration(cutscene_handler.cutscene_dir, delta)
		move_and_slide()
		return
		
	knockback = lerp(knockback, Vector2.ZERO, 0.1)
	
	
	if  state_machine.get_active_state()==hit or state_machine.get_active_state()==staggered:
		#hb_collison.disabled=true
		velocity.y += gravity * delta
		#velocity.x=0
		move_and_slide()
		return
	elif state_machine.get_active_state()==dying:
		death_handler.dying()
	elif state_machine.get_active_state()==death :
		hit_box_collision.disabled=true
		return
		
		
func teleport_counter():
	state_machine.dispatch(&"teleport_counter")
	
func teleport_atk():
	#print_debug(state_machine.get_active_state())
	state_machine.dispatch(&"teleport_atk")
		
func apply_gravity(delta : float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
		
		
func target_lock():
	Events.unlock_from.emit()
	target_lock_node.target_lock()
	locked_on=true
	
func makepath() -> void:
	nav_agent.target_position = player.global_position
	
func _on_navigation_timer_timeout() -> void:
	makepath()
	next_nav_point=nav_agent.get_next_path_position()

func player_behind_check():
	if (player_right and animated_sprite_2d.scale.x>0) or\
	 (not player_right and animated_sprite_2d.scale.x<0):
		hit_box.active=false
		hurt_box.weakpoint=true
		player_behind=true
	else:
		player_behind=false
		hurt_box.weakpoint=false
		
func get_width() -> int:
	return collision_shape_2d.get_shape().radius
func get_height() -> int:
	return collision_shape_2d.get_shape().radius+10
	
	
	

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	pass # Replace with function body.


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass # Replace with function body.



func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and state_machine.get_active_state()!=staggered:
		if player.attack_state.get_active_state()==player.dash_attack or player.attack_state.get_active_state()==player.attack_closer:
			pass
		else:
			pass
		state_machine.dispatch(&"start_attack")
		
		
		

func _on_attack_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and not animation_player.is_playing() and state_machine.get_active_state()!=staggered:
		state_machine.dispatch(&"start_chase")


func _on_stagger_staggered() -> void:
	if not phases_handler.is_final_phase():
		if health.health<=phases_handler.phases.get(phases_handler.cur_phase-1):
			return
	hit_stop.hit_stop(0.01, 0.5)
	hit_box_collision.call_deferred("set_disabled", true)
	hurt_box_collision.set_deferred("disabled", false)
	hit_box.active=false
	hurt_box.active=true
	state_machine.dispatch(&"staggered")
	assert(state_machine.get_active_state()==staggered)
	Events.camera_shake.emit(2,20)


func _on_stagger_stagger_decreased(diff: int) -> void:
	boss_ui.set_boss_stagger_smooth(stagger.stagger)


func _on_hurt_box_received_damage(damage: int) -> void:
	if changing_phase:
		return
	hit_box.clash_active=false
	boss_ui.set_boss_health_smooth(health.health)
	boss_ui.set_boss_stagger_smooth(stagger.stagger)
	if not phases_handler.is_final_phase():
		if health.health<=phases_handler.phases.get(phases_handler.cur_phase-1):
			hit_stop.hit_stop(0.2, 2)
			phases_handler.phase_change(health.health)
	if state_machine.get_active_state()==land:
		Events.camera_shake.emit(2,2)
		vfx_player.play("hit_down")
		hit_stop.hit_stop(0.1, 0.01)
		return
	if state_machine.get_active_state()!=staggered:
		hit_fx_player.play("hit")
	else:
		state_machine.dispatch(&"hit")
	#######################################################
	###Play hit animation, depending on staggered or not###
	#######################################################
	
	
func _on_hurt_box_bullet_hit(_damage: int) -> void:
	if state_machine.get_active_state()==staggered:
		launch.launch_strength=80.0
		if player_right:
			launch.knock_back_strength=-500.0
		else:
			launch.knock_back_strength=500.0
		print_debug(state_machine.get_active_state())
		state_machine.dispatch(&"launched")
		pass
	else:
		hit_stop.hit_stop(0.1, 0.1)
		hit_fx_player.play("hit")
		


func _on_health_health_depleted() -> void:
	parry_timer.stop()
	hit_box_collision.disabled=true
	movement_handler.active=false
	animated_sprite_2d.scale.x = 1
	if player_right:
		knockback.x=-250
	else:
		knockback.x=250
	jump_handler.handle_jump(0.2)
	if not death_cutscene:
		death_handler.death()
	else:
		animation_player.stop()
		Events.unlock_from.emit()
		Events.boss_died.emit("miniboss_hallway_death")
		set_process(false)
		set_physics_process(false)
		Events.global_flag_trigger.emit("miniboss_hallway_death")
		set_deferred("visible", false)
		state_machine.change_active_state(death)
		
	
func _on_turret_shoot_bullet() -> void:
	shoot_handler.shoot_bullet()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if state_machine.get_active_state()==death:
		queue_free()


func _on_attack_entered() -> void:
	if combat_state_machine.get_active_state()==melee_state:
		animation_player.play(melee_attack_manager.atk_type)
	
func _on_attack_exited() -> void:
	hurt_box.active=true
	movement_handler.face_player_active=true

func _on_attack_updated(delta: float) -> void:
	if attacking and state_machine.get_active_state()!=staggered:
		player_behind_check()
		if player_behind:
			hurt_box.active=true
		else:
			hurt_box.active=false


func _on_hit_box_area_entered(area: Area2D) -> void:
	if dash_attacking and not attacking:
		animation_player.play_section_with_markers(&"atk_dash", &"atk_dash_hit")
		hit_stop.hit_stop(0.1,1)
		

func _on_staggered_entered() -> void:
	hurt_box.staggered=true
	parry_timer.start(5)

func _on_staggered_exited() -> void:
	hurt_box.staggered=false
	if phases_handler.is_final_phase():
		pass
	else:
		phases_handler.phase_change(health.health)



func _on_bullet_detection_bullet_detected() -> void:
	if attacking and hit_box.heavy_attack:
		return
	if state_machine.get_active_state()==clashed_state:
		return
		

func _on_dying_entered() -> void:
	boss_ui.deactivate_boss_ui()


func _on_phasetransition_entered() -> void:
	hurt_box.active=false
	hit_box.active=false
	
	state_machine.add_transition(attack, teleport_and_shoot, &"teleport_counter")
	state_machine.add_transition(launch, teleport_and_shoot, &"teleport_counter")
	state_machine.add_transition(clashed_state, teleport_and_shoot, &"teleport_counter")
	state_machine.add_transition(staggered, teleport_and_shoot, &"teleport_recover")
	state_machine.add_transition(chasing, teleport_and_hit, &"teleport_atk")
	state_machine.add_transition(clashed_state, teleport_and_hit, &"teleport_atk")
	state_machine.add_transition(attack, teleport_and_hit, &"teleport_atk")
	
	state_machine.add_transition(teleport_and_shoot, attack, teleport_and_shoot.success_event)
	state_machine.add_transition(teleport_and_hit, attack, teleport_and_hit.success_event)
	
	melee_attack_manager.combo_max=4

func _on_phasetransition_exited() -> void:
	hurt_box.active=true
	hit_box.active=false
	phases.dispatch(&"next_phase")

func _on_phases_handler_next_phase() -> void:
	hurt_box_collision.call_deferred("set_disabled", true)
	changing_phase=true
	if state_machine.get_active_state()==death or\
	 state_machine.get_active_state()==dying:
		return
	else:
		state_machine.dispatch(&"begin_next_phase")

func _on_phase_2_entered() -> void:
	launch.air_time=0.5
	combat_state_machine.ranged_dist=1000


func _on_teleport_and_shoot_entered() -> void:
	hurt_box.set_collision_layer_value(7, false)
	print_debug("worked")
	


func _on_teleport_and_shoot_exited() -> void:
	hurt_box.set_collision_layer_value(7, true)
	hurt_box.active=true
	teleport_raycast_helper.target_position=Vector2(0,50)
	attacking=false
	var _colliding_bodies=attack_range.get_overlapping_bodies()
	for i in range(_colliding_bodies.size()-1, -1, 0):
		if _colliding_bodies[i].is_in_group("player"):
			state_machine.dispatch(&"start_attack")
		else:
			state_machine.dispatch(&"start_attack")
			

func _on_teleport_and_hit_updated(delta: float) -> void:
	#teleport_helper_raycast.look_at(Vector2(player.global_position.x, player.global_position.y-100))
	teleport_raycast_helper.target_position=player.global_position-teleport_raycast_helper.global_position
	print_debug(player.global_position, " ", teleport_raycast_helper.target_position)
	animated_sprite_2d.use_parent_material=true

func _on_teleport_and_hit_exited() -> void:
	hurt_box.active=true
	animated_sprite_2d.use_parent_material=false
	var _colliding_bodies=attack_range.get_overlapping_bodies()
	for i in range(_colliding_bodies.size()-1, -1, 0):
		if _colliding_bodies[i].is_in_group("player"):
			state_machine.dispatch(&"start_attack")


func death_on_cutscene() -> void:
	state_machine.change_active_state(death)
	

func _on_death_entered() -> void:
	animation_player.play("dead")
	
func boss_reset() -> void:
	if spawned:
		queue_free()
	else:
			
		process_mode=Node.PROCESS_MODE_INHERIT
		vision_handler.active=vision_active
		vision_handler.stay_on=vision_stay_on
		vision_handler.always_on=vision_always_on
		combat_state_machine.ranged_dist=100
		dying.blackboard.set_var("hit_the_floor", false)
		is_on_screen=false
		animation_player.stop()
		state_machine.change_active_state(idle)
		state_machine.restart()
		combat_state_machine.change_active_state(ranged_state)
		combat_state_machine.restart()
		phases.change_active_state(phase_1)
		phases.restart()
		health.health=health.max_health
		stagger.stagger=stagger.max_stagger
		movement_handler.active=false
		phases_handler.reset_phases()
		#process_mode=Node.PROCESS_MODE_DISABLED
		set_process(false)
		set_physics_process(false)
		state_machine.remove_transition(attack, &"teleport_counter")
		state_machine.remove_transition(staggered, &"teleport_recover")
		state_machine.remove_transition(chasing, &"teleport_atk")
		state_machine.remove_transition(teleport_and_shoot, teleport_and_shoot.success_event)
		state_machine.remove_transition(teleport_and_hit, teleport_and_hit.success_event)
		teleport_handler.teleport_dir_helper_rc.global_position=global_position
		teleport_handler.teleport_dir_helper_rc.top_level=false
		boss_reloaded.emit()
		#_ready()
	
func game_over() -> void:
	#boss_ui.visible=false
	boss_ui.set_deferred("visible", false)
	state_machine.change_active_state(idle)
	#process_mode=Node.PROCESS_MODE_DISABLED

func boss_activate() -> void:
	process_mode=Node.PROCESS_MODE_INHERIT
	set_process(true)
	set_physics_process(true)
	
func _on_hurt_box_launched() -> void:
	state_machine.change_active_state(launch)
		
func pushed_back(_force:=100):
	var _face_dir
	if player_right:
		_face_dir = 1
	else:
		_face_dir = -1
	
	velocity.x=-_force*_face_dir
	
func _on_launch_entered() -> void:
	hit_box_collision.set_deferred("disabled", true)
	hurt_box_collision.set_deferred("disabled", false)
	attack_timer.stop()
	vision_handler.active=false
	combat_state_machine.active=false
	stun_timer.stop()

func _on_launch_timer_timeout() -> void:
	if phases.get_active_state()==phase_2:
		teleport_counter()
	else:
		state_machine.dispatch(&"falling")
		
func _on_land_landed() -> void:
	hit_box_collision.set_deferred("disabled", true)
	hurt_box.active=true
	hurt_box_collision.set_deferred("disabled", false)
	set_collision_mask_value(13, true)
	vision_handler.active=true
	combat_state_machine.active=true
	state_machine.dispatch(&"resume_attack")
	stagger.set_temporary_immortality(3)
	#phases_handler.phase_change(health.health)
	if not phases_handler.is_final_phase():
		if health.health<=phases_handler.phases.get(phases_handler.cur_phase-1):
			hit_stop.hit_stop(0.2, 2)
			phases_handler.phase_change(health.health)
		
func _on_land_exited() -> void:
	hurt_box.staggered=false
	var _colliding_bodies=attack_range.get_overlapping_bodies()
	if _colliding_bodies!= null or _colliding_bodies.is_empty():
		pass
	else:
		for i in range(_colliding_bodies.size()-1, -1, 0):
			if _colliding_bodies[i].is_in_group("player"):
				state_machine.dispatch(&"start_attack")
				break
		
func _on_hit_box_clashed() -> void:
	#stun_timer.start(0.5)
	print_debug("clashed!")
	if hit_box.heavy_attack:
		return
	else:
		var _heavy_atk_min := melee_attack_manager.heavy_atk_min
		_heavy_atk_min +=5
		melee_attack_manager.set_heavy_atk_min(_heavy_atk_min)
	
	attacking=false

	boss_ui.set_boss_stagger_smooth(stagger.stagger)
	vfx_sprite.set_deferred("visible", false)
	state_machine.dispatch(&"clashed")

func _on_clashed_state_riposte_follow_up() -> void:
	hurt_box_collision.set_deferred("disabled", false)
	animation_player.play("atk_3")


func _on_clashed_state_updated(delta: float) -> void:
	set_collision_mask_value(24, true)
	hurt_box.set_collision_mask_value(24, true)

func stunned_hit(_launch: float = 0, _knockback: float = 0, _impact_dir_right: bool = true, _damage: int = 1) -> void:
	hit.hit_anim="knocked_back"
	if player_right:
		knockback.x=-_knockback
	else: 
		knockback.x=_knockback
	velocity.y=-_launch
	state_machine.dispatch(&"interrupt_knockback")
	if state_machine.get_active_state()!=land and state_machine.get_active_state()!=staggered:
		stagger.stagger-= _damage
	boss_ui.set_boss_stagger_smooth(stagger.stagger)
	hurt_box_collision.set_deferred("disabled", false)
	hurt_box.active=true
	stun_timer.start(1)
	
func _on_stun_timer_timeout() -> void:
	if state_machine.get_active_state()==staggered:
		return
	hurt_box_collision.set_deferred("disabled", false)
	
func counter_clash() -> void:
	if phases.get_active_state()==phase_1:
		melee_attack_manager.atk_resume_helper()
		state_machine.dispatch(&"resume_attack")
	else:
		if randi_range(0,1)==0:
			state_machine.dispatch(&"teleport_hit")
		else:
			state_machine.dispatch(&"teleport_shoot")
	
func player_damage(_value := 1) -> void:
	player.health.health-=_value
	
func player_knockback(_knockback_strength := 100.0, _launch_strength :=-15.0) -> void:
	var _face_dir = func() : if player_right: return 1 else: return -1
	player._on_knockback(_knockback_strength, _launch_strength, _face_dir.call())
	player.knockback_recovery_timer.start(1.0)


func _on_clashed_state_nothing_follow_up() -> void:
	pass # Replace with function body.
