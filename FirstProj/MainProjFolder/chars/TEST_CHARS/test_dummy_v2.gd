extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var hurt_box: HurtBox = $HurtBox
@onready var hb_collision: CollisionShape2D = $HurtBox/CollisionShape2D

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

@onready var target_lock_node: TargetLock = $TargetLock

@onready var bullet_detection: BulletDetection = $BulletDetection
@onready var bullet_detection_col: CollisionShape2D = $BulletDetection/CollisionShape2D

@onready var stagger: Stagger = $Stagger
@onready var health: Health = $Health
@onready var label: Label = $Label

@onready var state_machine: LimboHSM = $StateMachine
@onready var idle: LimboState = $StateMachine/idle
@onready var tree_test_state: BTState = $StateMachine/TreeTestState
@onready var death: Death = $StateMachine/Death
@onready var launched: LimboState = $StateMachine/Launched

@onready var teleport_dir_helper_rc: RayCast2D = $TeleportDirHelperRC
@onready var teleport_timer: Timer = $TeleportTimer

@onready var launch_timer: Timer = $LaunchTimer
@onready var launch_height : float = 40
@onready var launch_strength : float = 40

var is_on_screen : bool
@onready var on_screen: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D2



func _ready() -> void:
	pass
	_init_state_machine()




func _process(delta: float) -> void:
	pass
	#label.text="H: " + str(health.health) + " S: " + str(stagger.stagger)
	

		
	#label.text=str(global_position, " ", (global_position+teleport_dir_helper_rc.target_position))

func _physics_process(delta: float) -> void:
	
	if state_machine.get_active_state()!=launched:
		apply_gravity(delta)
	else:
		global_position.y=lerpf(global_position.y, launch_height, 0.1)
	move_and_slide()
	#print_debug(velocity)
		
func apply_gravity(delta : float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func _init_state_machine() -> void:
	state_machine.initial_state=idle
	state_machine.initialize(self)
	state_machine.set_active(true)

	
	
func target_lock():
	Events.unlock_from.emit()
	target_lock_node.target_lock()
	
func get_width() -> int:
	return abs(collision_shape_2d.get_shape().size.x * scale.x)
func get_height() -> int:
	return abs(collision_shape_2d.get_shape().size.y * scale.y)
	
	


func _on_hurt_box_launched() -> void:
	print_debug("launched")
	launch_timer.start(1)
	state_machine.change_active_state(launched)
	launch_height=global_position.y-launch_strength


func _on_launch_timer_timeout() -> void:
	state_machine.change_active_state(idle)


func _on_hurt_box_received_damage(damage: int) -> void:
	label.visible=true
	teleport_timer.start()


func _on_teleport_timer_timeout() -> void:
	label.visible=false
