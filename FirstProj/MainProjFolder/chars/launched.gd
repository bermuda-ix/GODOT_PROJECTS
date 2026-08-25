class_name Launch extends LimboState

@export var actor : Node2D
@export var launch_timer : Timer
@export var air_time : float = 1.0
@export var launch_height : float = 0
@export var launch_strength : float = 40
@export var knocked_back : float = 0
@export var knock_back_strength : float = 40
@export var animation_player : AnimationPlayer

func _enter() -> void:
	launch_height=actor.global_position.y-launch_strength
	knocked_back=actor.global_position.x-knock_back_strength
	actor.velocity.x=knock_back_strength
	actor.velocity.y=-launch_strength*10
	actor.current_speed=0
	animation_player.play("launched")

func _update(delta: float) -> void:
	
	actor.velocity.y=lerpf(actor.velocity.y, 0, 0.1)
	
	actor.velocity.x=lerpf(actor.velocity.x, knock_back_strength/2, 0.1)
	print_debug(actor.velocity.x)
	if actor.velocity.y>=-5.0 and launch_timer.is_stopped():
		launch_timer.start(air_time)
	elif actor.velocity.y>0 or (actor.velocity.y==0 and actor.is_on_floor()):
		launch_timer.stop()
		launch_timer.timeout.emit()
	
func start_launch_timer(_value: float = air_time) -> void:
	launch_timer.start(_value)

func _exit() -> void:
	pass
