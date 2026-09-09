class_name ClashFail extends LimboState

@export var actor : Node2D
@export var animation_player : AnimationPlayer
@export var anim_name : StringName = "clash_fail"

func _enter() -> void:
	animation_player.play(anim_name)
