class_name HitStop

extends Node

func hit_stop(time_scale : float, duration : float):
	Engine.time_scale = time_scale
	await(get_tree().create_timer(duration * time_scale).timeout)
	Engine.time_scale = 1.0
