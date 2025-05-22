class_name Boundery

extends StaticBody2D

@onready var boundery_active : bool = true : set=set_active
@export var objective : Node2D

func set_active(value) -> void:
	boundery_active=value
	
func objective_complete() -> void:
	if objective.is_in_group("boss"):
		if objective==null:
			set_active(false)
