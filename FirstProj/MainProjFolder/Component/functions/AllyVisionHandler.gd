class_name AllyVisionHandler extends Node

@export var actor : Node
@export var ally_vision : RayCast2D
@onready var ally_found := false

func _process(delta: float) -> void:
	find_ally()

func find_ally():
	if ally_vision.is_colliding():
		var _ally : Node = ally_vision.get_collider()
		if _ally.is_in_group("offensive_enemy"):
			ally_found=true
	else:
		ally_found=false
