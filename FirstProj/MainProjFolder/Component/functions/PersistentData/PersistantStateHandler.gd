class_name PersistantStateHandler extends Node

@export var actor : Node2D
signal update_state(value : String)

func _ready() -> void:
	Events.save_states.connect(save_state)
	Events.load_states.connect(load_state)

func save_state():
	var _name=actor.get_path()
	var state = actor.get_state()
	GlobalSaveData.add_persistent_value(_name, str(state))
	
func load_state(value : String):
	update_state.emit(value)
