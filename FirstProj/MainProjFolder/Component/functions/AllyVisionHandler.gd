class_name AllyVisionHandler extends Node

@export var active : bool = true
@export var actor : Node
@export var ally_vision : RayCast2D
@export var state_machine : LimboHSM
@onready var ally_found := false

signal found_ally
signal ally_gone

func _ready() -> void:
	assert(ally_vision!=null)

func _process(delta: float) -> void:
	if not active:
		return
	else:
		find_ally()

func find_ally():
	if state_machine.get_active_state()==actor.dying or state_machine.get_active_state()==actor.death:
		return
	else:
		if ally_vision.is_colliding():
			var _ally : Node = ally_vision.get_collider()
			if _ally.is_in_group("offensive_enemy"):
				ally_found=true
				found_ally.emit()
		else:
			ally_found=false
			ally_gone.emit()
