extends LimboState

@export var actor : Node2D
@export var animation_player : AnimationPlayer

#Needs polish

func _enter() -> void:
	animation_player.play("dash_start")
	
	
func _exit() -> void:
	animation_player.play("dash_end")
	
