extends LimboState

@export var actor : Node2D
@export var bt_player : BTPlayer

func _enter() -> void:
	print("entering ranged")
	bt_player.blackboard.set_var("attack_mode", true)
