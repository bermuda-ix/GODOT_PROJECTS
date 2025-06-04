extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity
@export var state_machine : LimboHSM

func _enter() -> void:
	pc.anim_player.play("falling")

func _update(delta: float) -> void:
	if pc.is_on_floor():
		state_machine.dispatch(&"landing")
