class_name GetPlayerInfoHandler

extends Node

@export var actor : Node2D
var distance

func _process(delta: float) -> void:
	get_player_distance()
	#print(distance)

func _physics_process(delta: float) -> void:
	get_player_state(actor.player)
	get_player_relative_loc()

func get_player_state(player : PlayerEntity) -> void:
	actor.player_state=player.get_state_enum()
	
func get_player_relative_loc():
	if actor.player.global_position.x>actor.global_position.x:
		actor.player_right=true
	else:
		actor.player_right=false

func get_player_distance()->float:
	distance = abs(actor.global_position.x-actor.player.global_position.x)
	return distance
