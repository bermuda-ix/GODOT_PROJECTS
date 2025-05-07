class_name turret_location

extends Node2D

@export var turret : Turret
@onready var turret_loc : Vector2 : set = set_turr_loc, get = get_turr_loc

func set_turr_loc(value : Vector2) -> void:
	turret_loc=value
	
func get_turr_loc() -> Vector2:
	return turret_loc

func move_turret():
	turret.position=turret_loc
