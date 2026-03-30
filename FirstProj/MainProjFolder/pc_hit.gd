extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity
@export var state_machine : LimboHSM
@export var hit_buffer : Timer

func _enter() -> void:
	anim_player.play("hit")
	hit_buffer.start(anim_player.current_animation_length)
	pc.hurt_box_detect.call_deferred("set_disabled", true)




func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="hit":
		hit_buffer.stop()
		state_machine.dispatch(&"recovering")
