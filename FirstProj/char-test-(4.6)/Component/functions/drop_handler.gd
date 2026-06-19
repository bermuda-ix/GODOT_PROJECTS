class_name DropHandler extends Node

@export var chance : int = clampi(50, 0, 100)
@export var drop := preload("res://heart.tscn")
@export var actor : Node2D

func spawn_drop():
	var _drop_chance_roll = randi_range(0, 100)
	if _drop_chance_roll<chance:
		return
	else:
		var drop_inst=drop.instantiate()
		drop_inst.global_position = actor.global_position
		get_tree().current_scene.add_child(drop_inst)
