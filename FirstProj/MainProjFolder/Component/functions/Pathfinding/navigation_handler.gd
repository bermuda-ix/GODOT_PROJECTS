class_name NavigationHandler extends Node

@onready var player : PlayerEntity
@export var navigation_agent : NavigationAgent2D
@export var actor: Node2D
@export var nav_timer : Timer
@onready var next : Vector2

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	nav_timer.timeout.connect(_on_nav_timer_timeout)
	makepath()
	next=navigation_agent.get_next_path_position()
	
func path_valid() -> bool:
	if player == null or navigation_agent.target_position == null:
		return false
	else:
		return navigation_agent.is_target_reachable()

func makepath() -> void:
	navigation_agent.target_position = player.global_position
	print_debug(actor.global_position," ",navigation_agent.target_position," ",player.global_position)
	
	
func _on_nav_timer_timeout() -> void:
	makepath()
	next=navigation_agent.get_next_path_position()
