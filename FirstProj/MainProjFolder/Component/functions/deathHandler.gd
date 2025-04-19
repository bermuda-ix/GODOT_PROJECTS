class_name DeathHandler
extends Node

@export var actor: Node2D
@export var sm : LimboHSM
@export var animation_player : AnimationPlayer
@export var tree_active : bool = true


func death():
	#print("dying")
	Events.unlock_from.emit()
	#actor.parry_timer.stop()
	if tree_active:
		actor.bt_player.blackboard.set_var("attack_mode", false)
		actor.bt_player.restart()
	#actor.hit_stop.hit_stop(0.05,5)
	sm.dispatch(&"die")
	
	#print("dead")

func dead():
	pass
	
