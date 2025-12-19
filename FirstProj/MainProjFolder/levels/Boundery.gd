class_name Boundery

extends StaticBody2D

@onready var boundery_active : bool = true : set=set_active
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@export var objective : Node2D

func _ready() -> void:
	pass
	Events.boss_died.connect(objective_complete)

func set_active(value) -> void:
	boundery_active=value
	collision_shape_2d.disabled=value
	
func objective_complete() -> void:
	if boundery_active:
		if objective==null:
			set_active(false)
