extends LimboHSM

@export var actor : Node2D
@export var shooting_states : LimboHSM
@export var player_info : GetPlayerInfoHandler

#func _enter() -> void:
	#print("begin shoot")
	#
