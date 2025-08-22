class_name Teleport

extends LimboState

@export var actor : Node2D
@export var animation_player : AnimationPlayer
@export var delay_timer : float = 1.0

func _enter() -> void:
	animation_player.play("teleport")

func _exit() -> void:
	print("teleport exit")
