extends Node2D

@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D
@onready var is_open: PersistentDataHandler = $IsOpen


var open_flag : bool = false

func _physics_process(delta: float) -> void:
	if open_flag:
		path_follow_2d.progress +=5
	else:
		pass

func open():
	open_flag=true
	is_open.set_value()
