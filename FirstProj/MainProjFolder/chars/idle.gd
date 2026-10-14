class_name Idle

extends LimboState

@export var actor : Node2D
@export var animation_player : AnimationPlayer = null

func _enter() -> void:
	animation_player.speed_scale = 1
	animation_player.play("idle")

func _update(delta: float) -> void:
	if not animation_player.is_playing():
		animation_player.play("idle")
		
func _exit() -> void:
	pass
	#print_debug("exit idle")
