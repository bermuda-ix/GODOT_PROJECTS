class_name Clashed extends LimboState

@export var anim_player : AnimationPlayer
@export var state_machine : LimboHSM

func _enter() -> void:
	anim_player.play("clashed")
	
