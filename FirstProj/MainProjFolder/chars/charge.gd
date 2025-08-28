extends LimboState

@export var actor : Node2D
@export var animation_player : AnimationPlayer
@export var charge_timer : float = 1.0
@export var timer : Timer

func _enter() -> void:
	animation_player.play("heavy_charge")
	timer.start(charge_timer)
