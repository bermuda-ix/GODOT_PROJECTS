class_name GetPlayerInfoHandler

extends Node

@export var actor : Node2D

func _physics_process(delta: float) -> void:
	get_player_state(actor.player)
	get_player_relative_loc()

func get_player_state(player : PlayerEntity) -> void:
	actor.player_state=player.get_state_enum()
	
func get_player_relative_loc():
	if actor.player.global_position.x>actor.global_position.x:
		actor.player_right=true
	else:
		false
