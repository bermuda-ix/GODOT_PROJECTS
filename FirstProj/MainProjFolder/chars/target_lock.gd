extends Node2D

func target_lock(value: Vector2):
	var target_lock_inst
	const TARGET_LOCK = preload("res://Component/effects/target_lock.tscn")
	target_lock_inst=TARGET_LOCK.instantiate()
	add_child(target_lock_inst)
	print(str(position)," ",str(target_lock_inst.global_position))
