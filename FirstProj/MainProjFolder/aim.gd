extends LimboState
@export var pc : PlayerEntity
@export var anim_player : AnimationPlayer
@export var shotty_anim_player : AnimationPlayer

func _enter() -> void:
	shotty_anim_player.play("shotgun_aim")

func _update(delta: float) -> void:
	if Input.is_action_just_pressed("walk_left") or Input.is_action_just_pressed("walk_right"):
		anim_player.play("walk")

func _exit() -> void:
	shotty_anim_player.pause()
	
