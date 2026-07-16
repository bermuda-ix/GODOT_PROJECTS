@tool

class_name EventFlag extends Node

@export_enum("Cutscene", "Event", "Other") var flag_type : int
@export_flags("Cutscene", "Event", "Other", "Cutscene and Event:3") var flag_types = 0
@export var trigger_once : bool = true
@export var cutscene_name : String
@export var flag_active : bool = false : set = flag_toggle, get = get_active
@export var dialogue_only : bool = true
@export var single_cutscene : bool = true


@export var activate_on_global_flag: bool:
	set(value):
		activate_on_global_flag = value
		notify_property_list_changed()
@export var global_flag_name: String

func _validate_property(property: Dictionary) -> void:
	if property.name == "global_flag_name" and not activate_on_global_flag:
		property.usage |= PROPERTY_USAGE_READ_ONLY
	if property.name == "cutscene_name" and (flag_types!=1 and flag_types!=3):
		property.usage |= PROPERTY_USAGE_READ_ONLY
	if property.name == "dialogue_only" and (flag_types!=1 and flag_types!=3):
		property.usage |= PROPERTY_USAGE_READ_ONLY
	if property.name == "single_cutscene" and (flag_types!=1 and flag_types!=3):
		property.usage |= PROPERTY_USAGE_READ_ONLY

signal load_cutscene_queue(_cutscene_list : String)
signal play_cutscene(_cutscene_name : String)
signal play_cutscene_list()
signal event_flag_triggered

func _ready() -> void:
	Events.global_flag_trigger.connect(flag_activate_on_global)

func flag_toggle(_value: bool):
	flag_active=_value

func get_active() -> bool:
	return flag_active

func flag_activate_on_global(_flag_name : String):
	flag_active=true

func flag_triggered() -> void:
	if not flag_active:
		return
	else:
		print_debug("local flag activate")
		#collision_shape_2d.disabled=true
		match flag_types:
			1:
				if single_cutscene:
					play_cutscene.emit(cutscene_name)
				else:
					play_cutscene_list.emit()
			2:
				event_flag_triggered.emit()
		if trigger_once:
			flag_toggle(false)
