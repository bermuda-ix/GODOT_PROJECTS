class_name entry_way extends Area2D

#signal player_entered_door(door : Door, transition_type : String)
signal enter_area(room : PackedScene)

@export_enum("left", "right") var entry_dir
@export var entry_loc : Vector2 = Vector2(0,0)
@export var new_scene_path : String
@export var entry_name : String
@onready var player : PlayerEntity
@export var exit : int

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func _on_body_entered(body: Node2D) -> void:
	if not body is PlayerEntity:
		return
	#player_entered_door.emit(self)
	player.next_room= LevelsList.levels[new_scene_path]
	player.in_door_way=true
#	SceneManager.load_new_scene(new_scene_path, transition_type)
	#queue_free()

func get_player_entry_dir() -> String:
	var player_dir = "left"
	match entry_dir:
		0:
			player_dir="left"
		1:
			player_dir="right"
	
	return player_dir

func get_player_entry_loc() -> Vector2:
	return entry_loc
