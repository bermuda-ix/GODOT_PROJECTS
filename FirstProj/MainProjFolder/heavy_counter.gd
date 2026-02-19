extends LimboState

@export var pc : PlayerEntity
@export var animation_player : AnimationPlayer
@export var state_machine : LimboHSM

func _enter() -> void:
	animation_player.play("Heavy_Counter")
	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="Heavy_Counter":
		if not Input.is_anything_pressed():
			state_machine.dispatch(&"return_to_idle")
		elif Input.is_action_pressed("attack"):
			state_machine.dispatch(&"start_attack")
		elif Input.is_action_pressed("special_attack"):
			state_machine.dispatch(&"aim")
