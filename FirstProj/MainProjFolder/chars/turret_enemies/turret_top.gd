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


#debug var
var state : String
@onready var debug: Label = $debug

func _ready():
	player = get_tree().get_first_node_in_group("player")
	turret.setup(0)
	turret.shoot_timer.paused=true
	_init_state_machine()
	


func _process(_delta):
	vision_handler.handle_vision()
	#shoot_attack_manager.shoot()
	var player_track_angle_wrap=wrapf(player_tracker_pivot.rotation, 0, 2*PI)
	debug.text=str(rad_to_deg(player_track_angle_wrap), " ",sprite_2d.rotation_degrees)
	health.health=base.health.health
	
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
		turret.shoot_timer.paused=false
	if previous==stagger:
		base.stagger_recover()

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
