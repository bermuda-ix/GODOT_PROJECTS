extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity

func _enter() -> void:
	anim_player.speed_scale=1.5
	anim_player.play("shotgun_finish")

func _exit() -> void:
	pc.set_shotgun_free_rotate(true)
	pc.reset_combo_flag=true
