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
	actor.velocity.x=knock_back_strength
	actor.velocity.y=-launch_strength*10
	#launch_timer.start(air_time)

func _update(delta: float) -> void:
	
	actor.velocity.y=lerpf(actor.velocity.y, 0, 0.1)
	print_debug(actor.velocity.y)
	actor.velocity.x=lerpf(-knock_back_strength, -knock_back_strength/2, 0.5)
	if actor.velocity.y>=-5.0 and launch_timer.is_stopped():
		launch_timer.start(air_time)
