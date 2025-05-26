class_name Shooting

extends LimboState

@export var actor : Node2D
@export var bt_player : BTPlayer

func _enter() -> void:
	#print("begin shooting")
	actor.hb_collision.disabled=true
	
#func _exit() -> void:
	#print("exit")
