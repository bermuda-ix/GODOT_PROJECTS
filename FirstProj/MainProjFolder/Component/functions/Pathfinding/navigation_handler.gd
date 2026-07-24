class_name NavigationHandler extends Node

@onready var player : PlayerEntity
@export var navigation_agent : NavigationAgent2D
@export var actor: Node2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
func path_valid() -> bool:
	if player == null or navigation_agent.target_position == null:
		return false
	else:
		return navigation_agent.is_target_reachable()
