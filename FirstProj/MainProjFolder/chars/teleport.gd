class_name Teleport

extends LimboState

@export var actor : Node2D
@export var animation_player : AnimationPlayer
@export var delay_timer : float = 1.0

func _enter() -> void:
	if animation_player.has_animation("teleport"):
		animation_player.play("teleport")

func _exit() -> void:
	pass
	#print_debug("teleport exit")
