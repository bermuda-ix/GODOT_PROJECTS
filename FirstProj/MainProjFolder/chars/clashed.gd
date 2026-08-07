class_name Clashed extends LimboState

@export var anim_player : AnimationPlayer
@export var vfx_player : AnimationPlayer
@export var state_machine : LimboHSM
@export var hit_stop : HitStop
@export var clash_anim_name : StringName = "clashed"

func _enter() -> void:
	if vfx_player != null:
		if vfx_player.has_animation(clash_anim_name):
			vfx_player.play(clash_anim_name)
	hit_stop.hit_stop(0.01, 0.25)
	vfx_player.speed_scale=1/Engine.time_scale
