extends LimboState

@export var actor : Node2D
@export var bt_player : BTPlayer

func _enter() -> void:
	print("melee range")
	actor.combat_state="Melee"
	bt_player.blackboard.set_var("melee_mode", true)
	bt_player.blackboard.set_var("ranged_mode", false)
	
func _exit() -> void:
	print("getting distance")
