class_name TargetLock
extends Node2D

@export var actor : Node2D

func target_lock():
	var target_lock_inst
	const TARGET_LOCK = preload("res://Component/effects/target_lock.tscn")
	target_lock_inst=TARGET_LOCK.instantiate()
	add_child(target_lock_inst)
	#print(str(position)," ",str(target_lock_inst.global_position))
