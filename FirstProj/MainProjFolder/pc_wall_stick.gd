extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity

func _enter() -> void:
	pc.anim_player.play("wall_stick")

func _update(delta: float) -> void:
	if pc.state_machine.get_active_state()==pc.wall_stick:
		if pc.is_on_floor():
			pc.state_machine.dispatch(&"return_to_idle")
