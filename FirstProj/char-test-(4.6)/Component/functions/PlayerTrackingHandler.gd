class_name PlayerTrackingHandler
extends Node

@export var actor : Node2D

func _process(delta: float) -> void:
	var direction_to_player : Vector2 = Vector2(actor.player.global_position.x, actor.player.global_position.y)\
	- actor.player_tracking.global_position
	
	actor.player_tracker_pivot.look_at(actor.player.global_position)
