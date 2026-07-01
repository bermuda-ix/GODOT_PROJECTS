extends LimboState

@export var anim_player : AnimationPlayer
@export var shotty_anim_player : AnimationPlayer
@export var state_machine : LimboHSM
@export var pc : PlayerEntity
@export var shoot_anim : StringName = "shotgun_attack"

func _enter() -> void:
	anim_player.play("shotgun_attack")
	pc.s_atk=true
	if state_machine.get_previous_active_state()==pc.flip_state:
		pc.velocity.x=75*-pc.face_dir
		pc.velocity.y=-25
	elif state_machine.get_previous_active_state()==pc.flip_end_state:
		pc.velocity.x=75*(pc.face_dir)
		pc.velocity.y=-25
	else:
		pc.velocity=Vector2.ZERO

func _exit() -> void:
	shotty_anim_player.play("shotgun_reset")
	pc.attacking=false
	pc.heavy_attack_flag=false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="shotgun_attack" or anim_name==shoot_anim:
		if pc.is_on_floor():
			pc.state_machine.dispatch(&"return_to_idle")
		else:
			pc.state_machine.dispatch(&"return_from_special")
		pc.s_atk=false
