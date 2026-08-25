class_name LandedState extends LimboState

@export var actor : Node2D
@export var animation_player : AnimationPlayer

func _enter() -> void:
	actor.knocked_back=false
	animation_player.play("landed")
