extends Node

const SAVE_PATH := "user://"

signal game_save
signal game_load
signal auto_save
signal save_level_state
signal load_level_state
signal clean_start

const default_save : Dictionary = {
	scene_path = "",
	player = {
		health = 10,
		max_health=10,
		stagger=5,
		max_stagger=5,
		pos_x = 0,
		pos_y=0
	}
}

var current_save : Dictionary = {
	scene_path = "",
	player = {
		health = 10,
		max_health=10,
		stagger=5,
		max_stagger=5,
		pos_x = 0,
		pos_y=0
	},
	flags={},
}

func reset_player_data() -> void:
	current_save["player"]["health"]=default_save["player"]["health"]
	current_save["player"]["max_health"]=default_save["player"]["max_health"]
	current_save["player"]["stagger"]=default_save["player"]["stagger"]
	current_save["player"]["max_stagger"]=default_save["player"]["max_stagger"]

var level_state : Dictionary = {
	scene_path="",
	items=[],
	persistence = {
		"" = ""
		},
	checkpoint_reached=""
	}
	
var heat_stats := {
		region_name = "ADV_FLASHBACK",
			heat = {
				current_heat_level="0",
				heat_gauge="0"
			}
		}
	
var score : int = 0
var score_name : String = "TEST"



var highscores

#Load initial persistant data
func _ready() -> void:
	load_highscores()


#Enter highscore
func store_score(highscore : Array) -> void:
	print_debug(highscores)
	if highscores.size()>=1:
		for i in range(highscores.size()-1, -1, -1):
			if highscores[i][0]==highscore[0]:
				print_debug("duplicate_name")
				highscores.remove_at(i)
				break
		highscores.append(highscore)
		highscores.sort_custom(sort_descending)
	else:
		highscores.append(highscore)
	print_scores()
	print_debug(highscores)
	save_highscores(highscores)
	
#Print all highscores
func print_scores() -> void:
	for _score in highscores:
		print_debug(_score[0], " ", _score[0]) 

#Helper functions for sorting highscores
static func sort_descending(a, b):
	if a[1]>b[1]:
		return true
	else:
		return false
static func sort_ascending(a, b):
	if a[1]<b[1]:
		return true
	else:
		return false


#JSONify highscore list
func highscores_array(_highscores: Array) -> Array:
	#Key:Value pair -> Score:Name
	var _highscore_table : Array[Array]
	for _score in _highscores:
		var _highscore : Array = [_score.name, _score.score]
		_highscore_table.append(_highscore)

	return _highscore_table

#Save highscores to file
func save_highscores(_highscores : Array) -> void:
	var _file = FileAccess.open( SAVE_PATH + "highscores//highscores_list.sav", FileAccess.WRITE_READ)
	if _file==null:
		var error_str: String = error_string(FileAccess.get_open_error())
		push_warning("Couldn't open file because: %s" % error_str)
	var _save_json = JSON.stringify(_highscores)
	_file.store_line(_save_json)
	_file.close()

func load_highscores() -> void:
	var _file = FileAccess.open( GlobalSaveData.SAVE_PATH + "highscores//highscores_list.sav", FileAccess.READ)
	var _load_json = JSON.new()
	var _parse_result = _load_json.parse(_file.get_line())
	if not  _parse_result == OK:
		print_debug("JSON Parse Error: ", _load_json.get_error_message(), " in ", _file, " as line ", _load_json.get_error_line())
		return
	highscores = _load_json.get_data() as Array[Array]
	print_debug(highscores)
	#highscores_sorted
	#for i in range(_loaded_scores.size()-1 , -1 , -1):
		#print_debug(_loaded_scores[i].name, _loaded_scores[i].score)

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
		print_debug("JSON Parse Error: ", _load_json.get_error_message(), " in ", _file, " as line ", _load_json.get_error_line())
		return
	var _save_dict_temp : Dictionary = _load_json.get_data() as Dictionary
	current_save=_save_dict_temp
# Load persistant data
func load_persistant_data() -> void:
	var _file = FileAccess.open( SAVE_PATH + "level_states//persistant_objects_states_json.sav", FileAccess.READ)
	var _load_json = JSON.new()
	var _parse_result = _load_json.parse(_file.get_line())
	if not  _parse_result == OK:
		print_debug("JSON Parse Error: ", _load_json.get_error_message(), " in ", _file, " as line ", _load_json.get_error_line())
		return
	var _save_dict_temp : Dictionary = _load_json.get_data() as Dictionary
	level_state=_save_dict_temp
	print_debug(level_state["persistence"])

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
