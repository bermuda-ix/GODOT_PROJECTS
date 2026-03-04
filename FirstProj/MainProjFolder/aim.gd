extends LimboState
@export var pc : PlayerEntity
@export var anim_player : AnimationPlayer
@export var shotty_anim_player : AnimationPlayer
@export var aim_speed_scale=1
@export var clash_power: ClashPower

func _enter() -> void:
	shotty_anim_player.speed_scale=aim_speed_scale+(clash_power.clash_power/2)
	shotty_anim_player.play("shotgun_aim")

func _update(delta: float) -> void:
	if Input.is_action_just_pressed("walk_left") or Input.is_action_just_pressed("walk_right"):
		anim_player.play("walk")

func _exit() -> void:
	shotty_anim_player.pause()
	shotty_anim_player.speed_scale=1
