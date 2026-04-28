extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity

func _enter() -> void:
	pc.set_shotgun_free_rotate(false)
	anim_player.speed_scale=1.5
	anim_player.play("shotgun_finish")
	pc.hit_fx_player.speed_scale=1.5
	pc.hit_animation="heavy_attack_landed"
	

func _exit() -> void:
	pc.reset_combo_flag=true
	pc.set_shotgun_free_rotate(true)
	pc.attacking=false
