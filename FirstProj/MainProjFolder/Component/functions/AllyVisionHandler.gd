class_name AllyVisionHandler extends Node

@export var actor : Node
@export var ally_vision : RayCast2D
@onready var ally_found := false

signal found_ally
signal ally_gone

func _ready() -> void:
	assert(ally_vision!=null)

func _process(delta: float) -> void:
	find_ally()

func find_ally():
	if ally_vision.is_colliding():
		var _ally : Node = ally_vision.get_collider()
		if _ally.is_in_group("offensive_enemy"):
			ally_found=true
			found_ally.emit()
	else:
		ally_found=false
		ally_gone.emit()
