class_name Slam

extends BTState

@export var actor : Node2D
@onready var slam: BTState = $"."


func _enter() -> void:
	print("BANANA SLAMMA")
	slam.blackboard.set_var("landed",false)
	actor.velocity.y=0

func _update(delta: float) -> void:
	actor.velocity.y+=actor.slam_vel * delta
	if actor.is_on_floor():
		slam.blackboard.set_var("landed",true)

func _exit() -> void:
	if actor.is_on_floor():
		print("landed correctly")
		Events.camera_shake.emit(3,15)
	else:
		print("exiting too soon")
