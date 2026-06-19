class_name DefendEnemyHandler extends Node

@export var ally_vision_handler : AllyVisionHandler
@export var defend_state : BTState
@export var actor : Node

func _ready() -> void:
	if ally_vision_handler.ally_found:
		defend_state.blackboard.set_var("ally_found", true)
	else:
		defend_state.blackboard.set_var("ally_found", false)
