class_name DeathHandler
extends Node

@export var actor: Node2D
@export var sm : LimboHSM
@export var animation_player : AnimationPlayer

func death():
	#print("dying")
	Events.unlock_from.emit()
	#actor.parry_timer.stop()
	sm.dispatch(&"die")
	animation_player.play("death")
	await animation_player.animation_finished
	animation_player.play("dead")
	
	#print("dead")
	
