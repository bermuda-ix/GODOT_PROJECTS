class_name PlayerTrackingHandler
extends Node

@export var actor : Node2D

func _process(delta: float) -> void:
	var direction_to_player : Vector2 = Vector2(actor.player.position.x, actor.player.position.y)\
	- actor.player_tracking.position
	
	actor.player_tracker_pivot.look_at(direction_to_player)
