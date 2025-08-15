extends Node2D

@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D
@onready var is_open: PersistentDataHandler = $IsOpen

@export var connected_switch : String


var open_flag : bool = false

func _ready() -> void:
	Events.unlock_door.connect(open_from_signal)
	is_open.get_value()
	if is_open.is_obj_active():
		pass
	
	
func _physics_process(delta: float) -> void:
	if open_flag:
		path_follow_2d.progress +=5
	else:
		pass

func open():
	open_flag=true
	is_open.set_value("open")
	#is_open.set_value()

#func debug_key():
	#if Input.is_action_just_pressed("DEBUG_KEY"):
		#open()
func open_from_signal(value : String = "default"):
	if value==connected_switch:
		open_flag=true

func _on_is_open_data_loaded() -> void:
	pass # Replace with function body.
