extends LimboState

@export var actor : Node2D

func _enter() -> void:
	actor.state="GUARD"
	actor.hb_collision.disabled=true
	actor.bt_player.blackboard.set_var("attack_mode", false)
	actor.animation_player.speed_scale = 1
	actor.animation_player.play("idle")
