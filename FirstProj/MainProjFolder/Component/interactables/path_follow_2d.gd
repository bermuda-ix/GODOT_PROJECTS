extends Node2D

@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D

var open_flag : bool = false

func _physics_process(delta: float) -> void:
	if open_flag:
		path_follow_2d.progress +=5
	else:
		pass

func open():
	open_flag=true
