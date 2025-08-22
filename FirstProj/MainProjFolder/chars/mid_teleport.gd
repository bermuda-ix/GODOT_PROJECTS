class_name MidTeleport

extends LimboState

@export var actor : Node2D
@export var animation_player : AnimationPlayer

func _enter() -> void:
	animation_player.play("mid_teleport")
	
func _exit() -> void:
	print("mid tele exit")
