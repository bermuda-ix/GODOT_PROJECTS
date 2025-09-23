class_name Attack

extends LimboState

@export var actor : Node2D
@export var bt_player : BTPlayer

func _enter() -> void:
	actor.state="ATTACK"
	#print("begin attack")
	#bt_player.blackboard.set_var("attack_mode", true)

#func _exit() -> void:
	#print("exit")
