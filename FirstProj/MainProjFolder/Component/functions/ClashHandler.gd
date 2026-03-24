class_name ClashHandler extends Node

@export var actor: Node2D
@export var animation_player : AnimationPlayer
@export var hit_stop : HitStop

func clashed_helper() -> void:
	animation_player.stop()
	hit_stop.hit_stop(0.05, 0.5)
	print_debug("clashed!")
	match actor.atk_chain:
		"_1":
			pass
		"_2":
			pass
		"_3":
			pass
		"_counter":
			pass
