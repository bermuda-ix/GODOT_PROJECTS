class_name Clashed extends LimboState

@export var anim_player : AnimationPlayer
@export var state_machine : LimboHSM

func _enter() -> void:
	if anim_player.has_animation("clashed"):
		anim_player.play("clashed")
	AudioStreamManager.play(SoundFx.SOCAPEX_SWORDSMALL_2)
