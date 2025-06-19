extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity

func _enter() -> void:
	pc.anim_player.play("Parry")
	pc.pb_rot.disabled=false

func _exit() -> void:
	pc.pb_rot.disabled=true
