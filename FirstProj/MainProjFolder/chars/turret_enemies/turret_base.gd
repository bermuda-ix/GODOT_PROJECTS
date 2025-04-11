class_name TurretBase
extends StaticBody2D

@onready var collision_shape_2d: CollisionShape2D = $Size/CollisionShape2D
@onready var target_lock_node: TargetLock = $TargetLock
@onready var on_screen: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

@onready var state_machine: LimboHSM = $StateMachine
@onready var death: LimboState = $StateMachine/Death
@onready var alive: LimboState = $StateMachine/Alive

func _init_state_machine():
	state_machine.initial_state=alive
	state_machine.initialize(self)
	state_machine.set_active(true)
	
	state_machine.add_transition(alive, death, &"death")

func dying():
	pass
	
func get_width() -> int:
	return collision_shape_2d.get_shape().size.x * scale.x
func get_height() -> int:
	return collision_shape_2d.get_shape().size.y * scale.y

func target_lock():
	Events.unlock_from.emit()
	target_lock_node.target_lock()
	


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	pass # Replace with function body.
