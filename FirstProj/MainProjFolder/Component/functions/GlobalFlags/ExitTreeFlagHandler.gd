class_name ExitTreeFlagHandler extends Node

@export var flag_name : String
@export var flag_type : String

func _exit_tree() -> void:
	match flag_type:
		"dialogue":
			Events.dialogue_flag_trigger.emit(flag_name)
