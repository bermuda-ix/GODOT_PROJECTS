class_name DefendEnemyHandler extends Node

@export var ally_vision_handler : AllyVisionHandler
@export var actor : Node

func _ready() -> void:
	if ally_vision_handler.ally_found:
		print("defending allie")
