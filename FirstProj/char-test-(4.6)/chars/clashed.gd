class_name Clashed extends LimboState

@export var anim_player : AnimationPlayer
@export var vfx_player : AnimationPlayer
@export var state_machine : LimboHSM

func _enter() -> void:
	if vfx_player != null:
		if vfx_player.has_animation("clashed"):
			vfx_player.play("clashed")
	
