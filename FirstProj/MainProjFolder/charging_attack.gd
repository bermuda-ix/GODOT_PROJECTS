extends LimboState

@export var anim_player : AnimationPlayer
@export var vfx_player : AnimationPlayer
@export var pc : PlayerEntity

func _enter() -> void:
	anim_player.pause()
	
func _exit() -> void:
	anim_player.play()
