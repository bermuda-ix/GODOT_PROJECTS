extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity

func _enter() -> void:
	anim_player.speed_scale=1.5
	anim_player.play("Attack_Dash")
	pc.hit_fx_player.speed_scale=1
	
func _exit() -> void:
	pc.reset_combo_flag=true
