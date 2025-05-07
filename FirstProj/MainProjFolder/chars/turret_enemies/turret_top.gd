class_name TurretTop

extends Node2D

@onready var turret_top_collision: CollisionShape2D = $Sprite2D/turret_top/turret_top_collision
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var turret_top: AnimatableBody2D = $Sprite2D/turret_top
@onready var hurt_box: HurtBox = $Sprite2D/HurtBox
@onready var hurt_box_collision: CollisionShape2D = $Sprite2D/HurtBox/turret_top_collision



const BALL_PROCETILE = preload("res://Component/ball_procetile.tscn")

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var player_tracker_pivot: Node2D = $PlayerTrackerPivot
@onready var player_tracking: RayCast2D = $PlayerTrackerPivot/PlayerTracking
@onready var vision_handler: VisionHandler = $VisionHandler

@onready var turret: Turret = $Sprite2D/Turret
@onready var shoot_attack_manager: ShootAttackManager = $ShootAttackManager
@onready var shoot_handler: ShootHandler = $ShootHandler

@onready var parry_timer: Timer = $ParryTimer
@onready var rotation_manager: RotationManager = $RotationManager

@onready var death_handler: DeathHandler = $DeathHandler

@onready var bt_player: BTPlayer = $BTPlayer

@onready var state_machine: LimboHSM = $LimboHSM
@onready var idle: LimboState = $LimboHSM/Idle
@onready var attack: LimboState = $LimboHSM/Attack
@onready var death: LimboState = $LimboHSM/Death
@onready var player : PlayerEntity = null
@onready var stagger: LimboState = $LimboHSM/Stagger
@onready var health: Health = $Health

@export var base : TurretBase

@onready var linked_turrets : Array[TurretBase]

#debug var
var state : String
@onready var debug: Label = $debug

func _ready():
	player = get_tree().get_first_node_in_group("player")
	turret.setup(0)
	turret.shoot_timer.paused=true
	bt_player.blackboard.set_var("shoot_active", false)
	_init_state_machine()
	player_tracking.target_position=Vector2(vision_handler.vision_range,0)

func _process(_delta):
	vision_handler.handle_vision()
	#shoot_attack_manager.shoot()
	var player_track_angle_wrap=wrapf(player_tracker_pivot.rotation, 0, 2*PI)
	debug.text=str(rad_to_deg(player_track_angle_wrap), " ",sprite_2d.rotation_degrees)
	health.health=base.health.health
	#if not shoot_attack_manager.shooting:
		#stagger_shooting()
	
func _init_state_machine():
	state_machine.initial_state=idle
	state_machine.initialize(self)
	state_machine.set_active(true)
	
	state_machine.add_transition(idle, attack, &"attack_mode")
	state_machine.add_transition(state_machine.ANYSTATE, death, &"die")
	state_machine.add_transition(state_machine.ANYSTATE, stagger, &"staggered")
	state_machine.add_transition(stagger, attack, &"recovery")



func _on_turret_shoot_bullet() -> void:
	print("shoot")
	shoot_handler.shoot_bullet()



func _on_limbo_hsm_active_state_changed(current: LimboState, previous: LimboState) -> void:
	if current==attack:
		print("activate turret")
		if previous==idle:
			vision_handler.always_on=true
			if not base.linked_turrets.is_empty():
				for i in range(base.linked_turrets.size()):
					
					if i == 0:
						base.linked_turrets[i].turret_top.state_machine.dispatch(&"attack_mode")
						base.linked_turrets[i].turret_top.bt_player.blackboard.set_var("shoot_active", true)
						base.linked_turrets[i].turret_top.shoot_attack_manager.shooting=true
						print(base.linked_turrets[i].name, " activated")
						
					else:
						base.linked_turrets[i].turret_top.state_machine.dispatch(&"attack_mode")
						base.linked_turrets[i].turret_top.bt_player.blackboard.set_var("shoot_active", false)
						print(base.linked_turrets[i].name, " waiting")
						
			else:
				bt_player.blackboard.set_var("shoot_active", true)
		else:
			pass
		turret.shoot_timer.paused=false
		
		#else:
			#bt_player.blackboard.set_var("shoot_active", true)
	if previous==stagger:
		base.stagger_recover()

				
func next_turret():
	if base.turret_link_order+1>=base.linked_turrets.size():
		base.linked_turrets[0].turret_top.bt_player.blackboard.set_var("shoot_active", true)
		print(base.linked_turrets[0].name, " activated")
			#base.linked_turrets[0].turret_top.state_machine.dispatch(&"attack_mode")
	else:
		base.linked_turrets[base.turret_link_order+1].turret_top.bt_player.blackboard.set_var("shoot_active", true)
		print(base.linked_turrets[base.turret_link_order+1].name, " activated")
					#base.linked_turrets[base.turret_link_order+1].turret_top.state_machine.dispatch(&"attack_mode")

func staggered()->void:
	parry_timer.start(3)
	rotation_manager.active=false
	state_machine.dispatch(&"staggered")


func _on_stagger_staggered() -> void:
	parry_timer.start(3)
	rotation_manager.active=false
	state_machine.dispatch(&"staggered")


func _on_parry_timer_timeout() -> void:
	rotation_manager.active=true
	state_machine.dispatch(&"recovery")


func _on_shoot_attack_manager_reloading() -> void:
	if base.linked_turrets.size()>1:
		base.linked_turrets[base.turret_link_order].turret_top.shoot_attack_manager.shooting=false
		base.linked_turrets[base.turret_link_order].turret_top.bt_player.blackboard.set_var("shoot_active", false)
		base.linked_turrets[base.turret_link_order].turret_top.bt_player.restart()
		for i in range(base.linked_turrets.size()):
			if i == base.turret_link_order:
				continue
			else:
				if base.linked_turrets[i].turret_top.shoot_attack_manager.shooting:
					print("waiting")
					print("next turret")
					return
		if base.turret_link_order+1>=base.linked_turrets.size():
			base.linked_turrets[0].turret_top.bt_player.blackboard.set_var("shoot_active", true)
			print(base.linked_turrets[0].name, " activated")
				#base.linked_turrets[0].turret_top.state_machine.dispatch(&"attack_mode")
		else:
			base.linked_turrets[base.turret_link_order+1].turret_top.bt_player.blackboard.set_var("shoot_active", true)
			print(base.linked_turrets[base.turret_link_order+1].name, " activated")
					#base.linked_turrets[base.turret_link_order+1].turret_top.state_machine.dispatch(&"attack_mode")
	else:
		pass
		
func _on_shoot_attack_manager_reloading_done() -> void:
	if base.linked_turrets.size()>1:
		pass
	else:
		bt_player.blackboard.set_var("shoot_active", true)
