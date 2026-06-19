class_name TeleportHandler extends Node

@export var actor : Node2D
@export var teleport_dir_helper_rc : RayCast2D

@export var _tele_left := -100
@export var _tele_right := 100
@export var _tele_height := 80



func teleport_away() -> void:
	
	
	if actor.player_right:
		actor.global_position=teleport((actor.global_position.x+_tele_left), (actor.global_position.y- _tele_height), actor.global_position)
	else:
		actor.global_position=teleport((actor.global_position.x+_tele_right), (actor.global_position.y- _tele_height), actor.global_position)
		
func teleport_to(front : bool, _teleport_loc : Vector2) -> void:
#	X-axis offset so objects ends up consistantly in front or behind of player
	var offset:= func():
		if front: return 10
		else: return -10
	
	if actor.player_right:
		actor.global_position=teleport(_teleport_loc.x-offset.call(),\
		 _teleport_loc.y,\
		 actor.global_position)
		#global_position.x+offset.call()
	else:

		actor.global_position=teleport(_teleport_loc.x+offset.call(),\
		 _teleport_loc.y,\
		 actor.global_position)




#Positive x and y moves right and up respectively
#Pass actor's global position and return result
func teleport(x_dir: float, y_dir: float, _global_position: Vector2) -> Vector2:

	teleport_dir_helper_rc.target_position.x=(x_dir)
	teleport_dir_helper_rc.target_position.y=(y_dir)
	
	if teleport_dir_helper_rc.is_colliding():
		teleport_dir_helper_rc.target_position=teleport_dir_helper_rc.get_collision_point()

	_global_position= teleport_dir_helper_rc.target_position
	return _global_position
