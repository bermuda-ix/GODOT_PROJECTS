extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity

func _enter() -> void:
	anim_player.speed_scale=1
	anim_player.play("Heavy_Combo_1")
	pc.heavy_attack_flag=true
	pc.reload_gun_amount(2)
	
#func _update(delta: float) -> void:
	#pass
	#pc.global_position.x = lerpf(pc.global_position.x, (pc.global_position.x - 15)*pc.face_dir, delta)

func _exit() -> void:
	pc.reset_combo_flag=true
	pc.heavy_attack_flag=false
	pc.set_shotgun_free_rotate(true)
	pc.attacking=false
