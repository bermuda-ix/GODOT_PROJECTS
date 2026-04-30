class_name Boundery

extends StaticBody2D


@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@export var boundery_active : bool = true : set=set_active
@export var objective : Node2D

func _ready() -> void:
	pass
	collision_shape_2d = $CollisionShape2D
	Events.boss_died.connect(objective_complete)
	Events.activate_arena.connect(activate_barrier)

func set_active(value) -> void:
	boundery_active=value
	collision_shape_2d = $CollisionShape2D
	collision_shape_2d.disabled=value
	
func objective_complete() -> void:
	if boundery_active:
		if objective==null:
			set_active(false)

func activate_barrier():
	var bosses=get_tree().get_nodes_in_group("Boss")
	if bosses.size()==1:
		objective=get_tree().get_first_node_in_group("Boss")
	else:
		for i in range(bosses.size()-1, -1, -1):
			if bosses[i].active==true:
				objective=bosses[i]
				break
			else:
				continue
	set_active(true)
