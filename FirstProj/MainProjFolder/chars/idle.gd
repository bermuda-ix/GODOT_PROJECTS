class_name Idle

extends LimboState

@export var actor : Node2D

func _enter() -> void:
	#actor.state="GUARD"
	actor.bt_player.blackboard.set_var("attack_mode", false)
	actor.animation_player.speed_scale = 1
	actor.animation_player.play("idle")
