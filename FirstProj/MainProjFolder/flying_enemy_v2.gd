extends CharacterBody2D


@onready var player : PlayerEntity = null
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

###Healh and hitbox
@onready var health: Health = $Health
@onready var stagger: Stagger = $Stagger
@onready var hurt_box: HurtBox = $HurtBox

###Movement
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var flying_movement_handler: FlyingMovementHandler = $FlyingMovementHandler
@onready var nav_timer: Timer = $NavTimer
@onready var current_speed : float = 0.0

###State Machin
@onready var state_machine: LimboHSM = $LimboHSM
@onready var idle: Idle = $LimboHSM/Idle
@onready var chasing: Chasing = $LimboHSM/Chasing
@onready var shooting_bt: ShootingBT = $LimboHSM/ShootingBT
@onready var dying_state: DyingState = $LimboHSM/DyingState
@onready var death: Death = $LimboHSM/Death

func _ready() -> void:
	_init_state_machine()

func _init_state_machine():
	state_machine.initial_state=chasing
	state_machine.initialize(self)
	state_machine.set_active(true)
	
	state_machine.add_transition(idle, chasing, &"begin_chase")
	
func _physics_process(delta: float) -> void:
	velocity=current_speed*flying_movement_handler.dir
	print_debug(current_speed)
	move_and_slide()
