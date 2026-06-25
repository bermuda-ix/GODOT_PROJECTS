@tool
class_name LocalFlag extends Node2D

@export_enum("Cutscene", "Event", "Other") var flag_type : int
@export var cutscene_name : String
@export var flag_active : bool = false
@export var dialogue_only : bool = true
@export var single_cutscene : bool = true
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D


@export var activate_on_global_flag: bool:
	set(value):
		activate_on_global_flag = value
		notify_property_list_changed()
@export var global_flag_name: String

func _validate_property(property: Dictionary) -> void:
	if property.name == "global_flag_name" and not activate_on_global_flag:
		property.usage |= PROPERTY_USAGE_READ_ONLY
	if property.name == "cutscene_name" and flag_type!=0:
		property.usage |= PROPERTY_USAGE_READ_ONLY
	if property.name == "dialogue_only" and flag_type!=0:
		property.usage |= PROPERTY_USAGE_READ_ONLY
	if property.name == "single_cutscene" and flag_type!=0:
		property.usage |= PROPERTY_USAGE_READ_ONLY

signal load_cutscene_queue(_cutscene_list : String)
signal play_cutscene(_cutscene_name : String)
signal play_cutscene_list()
signal event_flag_triggered

func _ready() -> void:
	collision_shape_2d.disabled=false
	Events.global_flag_trigger.connect(flag_activate_on_global)

func flag_toggle():
	flag_active!=flag_active

func flag_reset():
	collision_shape_2d.call_deferred("set_disabled", false)

func flag_activate():
	flag_active=true

func flag_activate_on_global(_flag_name : String):
	flag_active=true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and flag_active:
		print_debug("local flag activate")
		#collision_shape_2d.disabled=true
		collision_shape_2d.call_deferred("set_disabled", true)
		match flag_type:
			0:
				if single_cutscene:
					play_cutscene.emit(cutscene_name)
				else:
					play_cutscene_list.emit()
			1:
				event_flag_triggered.emit()
