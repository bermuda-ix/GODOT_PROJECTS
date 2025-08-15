class_name PersistentDataHandler extends Node

signal data_loaded
var value : bool = true


func _ready() -> void:
	get_value()
	pass

func set_value(state : String) -> void:
	GlobalSaveData.add_persistent_value( _get_name(), state )

func get_value() -> void:
	value = GlobalSaveData.check_persistent_value( _get_name() )
	data_loaded.emit( value )

func is_obj_active() -> bool:
	return GlobalSaveData.check_persistent_value( _get_name() )

func get_state(value : String) -> String:
	return GlobalSaveData.get_object_state(value)
	
	
	
func _get_name() -> String:
	return get_tree().current_scene.scene_file_path + "/" + get_parent().name + "/" + name
