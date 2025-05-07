class_name ranged

extends LimboState

@export var actor : Node2D
@export var bt_player : BTPlayer

func _enter() -> void:
	actor.combat_state="Ranged"
	print("ranged")
	bt_player.blackboard.set_var("ranged_mode", true)
	bt_player.blackboard.set_var("melee_mode", false)
				
	
func _exit() -> void:
	print("closing in")
	
