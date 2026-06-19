extends Node2D

@onready var stagger: Stagger = $Stagger
@onready var health: Health = $Health
@onready var label: Label = $Label
@onready var collision_shape_2d: CollisionShape2D = $CharacterBody2D/CollisionShape2D

@onready var teleport_dir_helper_rc: RayCast2D = $TeleportDirHelperRC
@onready var teleport_timer: Timer = $TeleportTimer


@onready var state_machine: LimboHSM = $StateMachine
@onready var idle: LimboState = $StateMachine/idle
@onready var tree_test_state: BTState = $StateMachine/TreeTestState
@onready var death: Death = $StateMachine/Death

@onready var hurt_box: HurtBox = $CharacterBody2D/HurtBox
@onready var on_screen: VisibleOnScreenNotifier2D = $CharacterBody2D/VisibleOnScreenNotifier2D
@onready var target_lock_node: TargetLock = $CharacterBody2D/TargetLock
@onready var bullet_detection: BulletDetection = $CharacterBody2D/BulletDetection
@onready var character_body_2d: CharacterBody2D = $CharacterBody2D





func _ready() -> void:
	pass
	#_init_state_machine()

func _process(delta: float) -> void:
	label.text="H: " + str(health.health) + " S: " + str(stagger.stagger)
	

		
	#label.text=str(global_position, " ", (global_position+teleport_dir_helper_rc.target_position))

func _init_state_machine() -> void:
	state_machine.initial_state=idle
	state_machine.initialize(self)
	state_machine.set_active(true)
	
	state_machine.add_transition(idle, tree_test_state, &"teleport_shoot")
	state_machine.add_transition(tree_test_state, idle, tree_test_state.success_event)
	
	
func target_lock():
	Events.unlock_from.emit()
	target_lock_node.target_lock()
	
func get_width() -> int:
	return abs(collision_shape_2d.get_shape().size.x * character_body_2d.scale.x)
func get_height() -> int:
	return abs(collision_shape_2d.get_shape().size.y * character_body_2d.scale.y)
	
func test_function():
	state_machine.dispatch(&"teleport_shoot")
	

func teleport_away():
	teleport_dir_helper_rc.target_position.x=(global_position.x-100)-teleport_dir_helper_rc.global_position.x
	teleport_dir_helper_rc.target_position.y=(global_position.y-40)-teleport_dir_helper_rc.global_position.y
	if teleport_dir_helper_rc.is_colliding():
		print_debug("blocked!")
		teleport_dir_helper_rc.target_position=-(global_position- teleport_dir_helper_rc.get_collision_point())
	print_debug("preparing to move to: ", (global_position+ teleport_dir_helper_rc.target_position), "from: ", global_position)
	global_position+= teleport_dir_helper_rc.target_position
	print_debug("teleporting to: ", global_position)

func prepare_teleport():
	
	teleport_timer.start()

func _on_hurt_box_received_damage(damage: int) -> void:
	pass # Replace with function body.

func _on_hurt_box_received_stagger_damage(damage: int) -> void:
	pass # Replace with function body.


func _on_hurt_box_area_entered(area: Area2D) -> void:
	pass
	#if area.is_in_group("PlayerBullet"):
		#stagger.stagger-=1


func _on_bullet_detection_bullet_detected() -> void:
	print_debug("bullet detected")
