extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity
@export var state_machine : LimboHSM

func _enter() -> void:
	anim_player.play("hit")
	pc.hurt_box_detect.disabled=true




func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="hit":
		state_machine.dispatch(&"recovering")
