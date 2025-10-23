class_name GlobalFlagHandler extends Node

@export_category("Flag Settings")
@export var flag_name : String = "No Flag"
@export var flag_active : bool
@export_category("Flag trigger")
@export var flag_triggered : bool = false

signal flag_activate

func _ready() -> void:
	Events.global_flag_trigger.connect(trigger_flag)
	
func trigger_flag(_flag : String) -> void:
	if _flag == flag_name:
		if flag_active:
			flag_triggered != flag_triggered
			flag_activate.emit()
	else:
		pass
		
