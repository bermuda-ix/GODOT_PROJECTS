extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity


func _enter() -> void:
	print("dodging")
	anim_player.play(pc.dodge_anim_run)
	pc.set_collision_mask_value(15, false)
	pc.counter_box_collision.disabled=false
	

#func _update(delta: float) -> void:
	#pc.global_position.x=move_toward(pc.global_position.x, pc.global_position.x+10*pc.dir.x, 10*delta)

func _exit() -> void:
	pc.velocity.x=0
	pc.counter_box_collision.disabled=true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name==pc.dodge_anim_run:
		pc.state_machine.dispatch(&"return_to_idle")
		pc.set_collision_mask_value(15, true)
