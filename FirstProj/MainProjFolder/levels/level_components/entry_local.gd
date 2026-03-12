extends Area2D

#signal player_entered_door(door : Door, transition_type : String)
signal enter_area(room : PackedScene)

@onready var test := false

@export_enum("left", "right") var entry_dir
@export var entry_loc : Vector2 = Vector2(0,0)
@export var entry : int = 0
@onready var entry_name : String
@onready var player : PlayerEntity

@export_category("Connected Entry")
@export var door : PackedScene
@export var locked : bool = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if not body is PlayerEntity:
		return

		


func get_player_entry_dir() -> String:
	var player_dir = "left"
	match entry_dir:
		0:
			player_dir="left"
		1:
			player_dir="right"
	
	return player_dir

func get_player_entry_loc() -> Vector2:
	if door == null:
		print_debug("the lock is broken")
		return global_position
	else:
		return door.global_position

func _on_body_exited(body: Node2D) -> void:
	if not body is PlayerEntity:
		return
	#player_entered_door.emit(self)
	player.in_door_way=false
#	SceneManager.load_new_scene(new_scene_path, transition_type)
	#queue_free()
