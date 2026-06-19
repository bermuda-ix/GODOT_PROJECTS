class_name Map extends Node

const MAP_SAVE_FOLDER : String = "User://map_saves/"

enum MapIDs {
	NONE = 0,
	BASE = 1,
	BASE_FLASHBACK = 2
}

@export var map_id : MapIDs

static  var current_map : Map

func _ready() -> void:
	current_map = self
	DirAccess.make_dir_absolute(MAP_SAVE_FOLDER)
	
	load_map_data()
	save_map_data()
	
func get_map_save_file_path() -> String:
	return MAP_SAVE_FOLDER + str("map_save_", map_id) + ".res"
	
func save_map_data() -> void:
	var new_save = MapSaveData.new()
	
	for save: SaveNode in get_tree().get_nodes_in_group(SaveNode.SAVE_NODE_GROUP):
		var node_path = get_path_to(save)
		new_save.data[node_path] = save.get_save_dict()
		
	ResourceSaver.save(new_save, get_map_save_file_path())
	print_debug("Saved map data to ", get_map_save_file_path())
	
func load_map_data() -> void:
	if not FileAccess.file_exists(get_map_save_file_path()):
		return
		
	print_debug("Loading map data from ", get_map_save_file_path())
	var loaded_save = ResourceLoader.load(get_map_save_file_path()) as MapSaveData
	
	for path in loaded_save.data:
		var save_node = get_node_or_null(path)
		if save_node:
			save_node.apply_save_data(loaded_save.data[path])
