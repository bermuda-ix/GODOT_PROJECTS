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
		},
	checkpoint_reached=""
	}
	
	
var score : int = 0
var score_name : String = "TEST"

#Save game functions
func save_game() -> void:
	save_player_data()
	save_persistant_data()

#	save player data
func save_player_data() -> void:
	var _file := FileAccess.open( SAVE_PATH + "player_data//stats//player_stats_json.sav", FileAccess.WRITE_READ)
	var _save_json = JSON.stringify(current_save)
	_file.store_line(_save_json)
	_file.close()

#	Save persistant data
func save_persistant_data() -> void:
	var _file = FileAccess.open( SAVE_PATH + "level_states//persistant_objects_states_json.sav", FileAccess.WRITE_READ)
	if _file==null:
		var error_str: String = error_string(FileAccess.get_open_error())
		push_warning("Couldn't open file because: %s" % error_str)
	var _save_json = JSON.stringify(level_state)
	_file.store_line(_save_json)
	_file.close()



#Load data functions
func load_game() -> void:
	load_player_data()
	load_persistant_data()
	

# Load player data
func load_player_data() -> void:
	var _file := FileAccess.open( SAVE_PATH + "player_data//stats//player_stats_json.sav", FileAccess.READ)
	var _load_json = JSON.new()
	var _parse_result = _load_json.parse(_file.get_line())
	if not  _parse_result == OK:
		print("JSON Parse Error: ", _load_json.get_error_message(), " in ", _file, " as line ", _load_json.get_error_line())
		return
	var _save_dict_temp : Dictionary = _load_json.get_data() as Dictionary
	current_save=_save_dict_temp
# Load persistant data
func load_persistant_data() -> void:
	var _file = FileAccess.open( SAVE_PATH + "level_states//persistant_objects_states_json.sav", FileAccess.READ)
	var _load_json = JSON.new()
	var _parse_result = _load_json.parse(_file.get_line())
	if not  _parse_result == OK:
		print("JSON Parse Error: ", _load_json.get_error_message(), " in ", _file, " as line ", _load_json.get_error_line())
		return
	var _save_dict_temp : Dictionary = _load_json.get_data() as Dictionary
	level_state=_save_dict_temp
	print(level_state["persistence"])

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
