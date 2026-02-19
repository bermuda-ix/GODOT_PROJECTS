class_name TeleportHandler extends Node

@export var teleport_dir_helper_rc : RayCast2D


#Positive x and y moves right and up respectively
#Pass actor's global position and return result
func teleport(x_dir: float, y_dir: float, _global_position: Vector2) -> Vector2:
	teleport_dir_helper_rc.target_position.x=(_global_position.x+x_dir)-teleport_dir_helper_rc.global_position.x
	teleport_dir_helper_rc.target_position.y=(_global_position.y-y_dir)-teleport_dir_helper_rc.global_position.y
	
	teleport_dir_helper_rc.target_position=Vector2(x_dir, -y_dir)
	if teleport_dir_helper_rc.is_colliding():
		print_debug("blocked!")
		teleport_dir_helper_rc.target_position=-(_global_position- teleport_dir_helper_rc.get_collision_point())
		#print_debug(teleport_dir_helper_rc.get_collision_point()," - ", teleport_dir_helper_rc.target_position)
		#teleport_dir_helper_rc.target_position-=teleport_dir_helper_rc.get_collision_point()
		#print_debug(teleport_dir_helper_rc.target_position)
		
	#print_debug("preparing to move to: ", (teleport_dir_helper_rc.target_position), "from: ", _global_position)
	_global_position= teleport_dir_helper_rc.target_position
	#print_debug("teleporting to: ", _global_position)
	return _global_position
