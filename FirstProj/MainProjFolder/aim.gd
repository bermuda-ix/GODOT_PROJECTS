extends LimboState
@export var pc : PlayerEntity
@export var anim_player : AnimationPlayer

func _enter() -> void:
	anim_player.play("shotgun_aim")

func _update(delta: float) -> void:
	if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
		anim_player.play("walk")
