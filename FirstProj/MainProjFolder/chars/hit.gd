extends LimboState

@export var actor : Node2D

func _enter() -> void:
	actor.state="Hit"
	actor.bt_player.blackboard.set_var("attack_mode", false)
