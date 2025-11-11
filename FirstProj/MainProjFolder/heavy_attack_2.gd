extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity

func _enter() -> void:
	pc.set_shotgun_free_rotate(false)
	anim_player.speed_scale=1.5
	anim_player.play("Heavy_Attack_2")
