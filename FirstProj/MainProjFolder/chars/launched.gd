class_name Launch extends LimboState

@export var actor : Node2D
@export var launch_timer : Timer
@export var launch_height : float = 0
@export var launch_strength : float = 40

func _enter() -> void:
	launch_height=actor.global_position.y-launch_strength
	launch_timer.start(1)
