class_name Clashed extends LimboState

@export var anim_player : AnimationPlayer
@export var vfx_player : AnimationPlayer
@export var state_machine : LimboHSM

func _enter() -> void:
	if vfx_player != null:
		if vfx_player.has_animation("clashed"):
			vfx_player.play("clashed")
	var _current_atk := anim_player.current_animation
	var _atk_clash_anim : StringName = _current_atk+"_connect"
	print_debug(_atk_clash_anim)
	#anim_player.stop()
	anim_player.play_section_with_markers(_current_atk, _atk_clash_anim)
	AudioStreamManager.play(SoundFx.SOCAPEX_SWORDSMALL_2)
