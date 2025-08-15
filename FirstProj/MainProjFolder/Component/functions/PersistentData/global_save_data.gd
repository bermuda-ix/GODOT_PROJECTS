extends Node

const SAVE_PATH = "user://"

signal game_save
signal game_load
signal auto_save
signal save_level_state
signal load_level_state
signal clean_start

var current_save : Dictionary = {
	scene_path = "",
	player = {
		health = 100,
		max_health=100,
		stagger=3,
		max_stagger=3,
		pos_x = 0,
		pos_y=0
	}
}

var level_state : Dictionary = {
	scene_path="",
	items=[],
	persistence = {
		"" : ""
		}
	}
	
func save_game() -> void:
	var file := FileAccess.open( SAVE_PATH + "player_data//stats//player_stats_json.sav", FileAccess.WRITE)
	var save_json = JSON.stringify(current_save)
	file.store_line(save_json)
	pass
	
func load_game() -> void:
	var file := FileAccess.open( SAVE_PATH + "player_data//stats//player_stats_json.sav", FileAccess.READ)
	var load_json = JSON.new()
	load_json.parse(file.get_line())
	var save_dict_temp : Dictionary = load_json.get_data() as Dictionary
	current_save=save_dict_temp
	pass

func load_player_stats() -> void:
	game_load.emit()

	
func save_level() -> void:
	pass
	
func load_level() -> void:
	pass
	
func add_persistent_value(value : String, state : String) -> void:
	level_state.persistence[value] = state
	pass
	
func check_persistent_value(value : String) -> bool:
	return level_state.has(value)

func get_object_state(value : String) -> String:
	return level_state.persistence.get(value)

func set_object_state(obj_name : String, value : String):
	level_state.persistence[obj_name]=value

func reset_level() -> void:
	clear_persistent_values()

func clear_persistent_values() -> void:
	level_state.persistence.clear()
