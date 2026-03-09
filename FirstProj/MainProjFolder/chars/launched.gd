class_name Launch extends LimboState

@export var actor : Node2D
@export var launch_timer : Timer
@export var air_time : float = 1.0
@export var launch_height : float = 0
@export var launch_strength : float = 40
@export var knocked_back : float = 0
@export var knock_back_strength : float = 40

func _enter() -> void:
	launch_height=actor.global_position.y-launch_strength
	knocked_back=actor.global_position.x-knock_back_strength
	launch_timer.start(air_time)
