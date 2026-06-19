extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity
@export var state_machine : LimboHSM


func _enter() -> void:
	pc.anim_player.play("landed")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="landed":
		state_machine.dispatch(&"return_to_idle")
