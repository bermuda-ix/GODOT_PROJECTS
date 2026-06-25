class_name entry_local extends Area2D

#signal player_entered_door(door : Door, transition_type : String)
signal enter_area(room : PackedScene)

signal locked_door

@onready var test := false

@export_enum("left", "right") var entry_dir
@export var entry_loc : Vector2 = Vector2(0,0)
@export var entry : int = 0
@onready var entry_name : String
@onready var player : PlayerEntity
@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var ui_timer: Timer = $UITimer
const local : bool = true

@export_category("Connected Entry")
@export var door : Node2D
@export var locked : bool = false


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if not body is PlayerEntity:
		return

		
func show_door_status() -> void:
	rich_text_label.set_deferred("visible", true)
	ui_timer.start(5)

func get_player_entry_dir() -> String:
	var player_dir = "left"
	match entry_dir:
		0:
			player_dir="left"
		1:
			player_dir="right"
	
	return player_dir

func get_lock_state() -> bool:
	return locked

func player_next_entry() -> Vector2:
	if door == null:
		print_debug("the lock is broken")
		return global_position
	else:
		if locked:
			if Input.is_action_just_pressed("Interact"):
				show_door_status()
			return global_position
		else:
			return door.global_position

func locked_door_attempt() -> void:
	locked_door.emit()

func _on_body_exited(body: Node2D) -> void:
	if not body is PlayerEntity:
		return
	#player_entered_door.emit(self)
	player.in_door_way=false
#	SceneManager.load_new_scene(new_scene_path, transition_type)
	#queue_free()

func lock() -> void:
	rich_text_label.text="LOCKED"
	show_door_status()
	set_deferred("locked", true)

func unlock() -> void:
	rich_text_label.text="UNLOCKED"
	show_door_status()
	set_deferred("locked", false)

func _on_ui_timer_timeout() -> void:
	rich_text_label.set_deferred("visible", false)
