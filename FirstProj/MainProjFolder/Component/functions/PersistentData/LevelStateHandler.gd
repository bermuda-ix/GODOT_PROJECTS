class_name LevelStateHandler extends Node

@export var level : Node2D

func _ready() -> void:
	Events.checkpoint_reached.connect(save_level_state)


func save_level_state():
	var _save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var persistant_nodes : Array[Node] =get_tree().get_nodes_in_group("Persistant")
	for node in persistant_nodes:
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue
		#if !node.has_method("save_state"):
			#print("persistent node '%s' is missing a save() function, skipped" % node.name)
			#continue
		#node.call("save_state")
		Events.save_states.emit()
	var _active_enemies_list : Array[Node] = get_tree().get_nodes_in_group("Enemy")
	var _active_enemy_names : Array[StringName]
	for _node in _active_enemies_list:
		_active_enemy_names.push_back(_node.name)
	var _active_enemies_json=JSON.stringify(_active_enemy_names)
	print(_active_enemies_json)
	_save_file.store_line(_active_enemies_json)



func load_level_state():
#	Update enemies to remove enemies from tree that are no longer active, based on what was saved
	var _save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	var _active_enemy_list : Array
	while _save_file.get_position() < _save_file.get_length():
		var _json_string = _save_file.get_line()
		var _json = JSON.new()
		var _parse_result = _json.parse(_json_string)
		if not _parse_result == OK:
			print("JSON Parse Error: ", _json.get_error_message(), " in ", _json_string, " as line ", _json.get_error_line())
			continue
		var _parse_data=_json.data
		if typeof(_parse_data)==TYPE_ARRAY:
			_active_enemy_list=_parse_data
	for _enemy in level.init_active_enemies_list:
		if is_instance_valid(_enemy):
			if _active_enemy_list.has(_enemy.name):
				continue
			else:
				_enemy.queue_free()
				
#	Update persistant objects sates based on what was saved
	GlobalSaveData.load_game()
	var _new_start_pos_x : float =GlobalSaveData.current_save["player"]["pos_x"]
	var _new_start_pos_y : float =GlobalSaveData.current_save["player"]["pos_y"]
	if _new_start_pos_x!=0 and _new_start_pos_y!=0:
		level.default.global_position.x=_new_start_pos_x
		level.default.global_position.y= _new_start_pos_y
	var _persistant_nodes : Array[Node] =get_tree().get_nodes_in_group("Persistant")
	for _node in _persistant_nodes:
		var _name=_node.get_path()
		if _node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % _node.name)
			continue
		if not GlobalSaveData.level_state["persistence"].has(str(_name)):
			print("persistent node '%s' is not in persistence dictionary, skipped" % _node.name)
			continue
		
		#print(GlobalSaveData.level_state["persistence"][str(_name)])
		var _state=GlobalSaveData.level_state["persistence"][str(_name)]
		Events.load_states.emit(_state)
		#_node.load_state(_state)
	#Events.load_checkpoint.emit()
