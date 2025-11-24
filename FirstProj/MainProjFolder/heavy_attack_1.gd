extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity

func _enter() -> void:
	anim_player.speed_scale=1.5
	anim_player.play("Heavy_Combo_1")
	pc.velocity.x=-250*(-pc.face_dir)
	pc.heavy_attack_flag=true
	
#func _update(delta: float) -> void:
	#pass
	#pc.global_position.x = lerpf(pc.global_position.x, (pc.global_position.x - 15)*pc.face_dir, delta)

func _exit() -> void:
	pc.reset_combo_flag=true
	pc.heavy_attack_flag=true
