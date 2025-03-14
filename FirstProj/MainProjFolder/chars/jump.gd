extends LimboState

@export var actor : Node2D

func _enter() -> void:
	actor.prev_speed=actor.current_speed
	#print("jumping")
	actor.state="JUMP"
	if actor.current_speed < 0:
		actor.current_speed = -actor.jump_speed
	else:
		actor.current_speed = actor.jump_speed
