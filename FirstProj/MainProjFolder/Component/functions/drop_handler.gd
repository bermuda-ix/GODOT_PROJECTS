class_name DropHandler extends Node

@export var chance : int = clampi(50, 0, 100)
@export var drop := preload("res://heart.tscn")
@export var actor : Node2D
@export var spawn_vel : Vector2

func spawn_drop():
	var _drop_chance_roll = randi_range(0, 100)
	if _drop_chance_roll>chance:
		return
	else:
		var drop_inst=drop.instantiate()
		if drop_inst.get_class()=="RigidBody2D":
			drop_inst.linear_velocity=spawn_vel
		drop_inst.global_position=Vector2(actor.global_position.x, actor.global_position.y-50)
		get_tree().current_scene.add_child(drop_inst)
