extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity

func _enter() -> void:
	anim_player.play("shotgun_attack")
	pc.s_atk=true
	pc.velocity=Vector2.ZERO



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="shotgun_attack":
		if pc.is_on_floor():
			pc.state_machine.dispatch(&"return_to_idle")
		else:
			pc.state_machine.dispatch(&"return_from_special")
		pc.s_atk=false
