class_name FallingState extends LimboState

@export var animation_player : AnimationPlayer
@export var actor : Node2D
@export var state_machine : LimboHSM

func _enter() -> void:
	animation_player.play("falling")
	
func _update(delta: float) -> void:
	if actor.is_on_floor():
		state_machine.dispatch(&"landed")
