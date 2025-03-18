class_name DeathHandler
extends Node

@export var actor: Node2D
@export var sm : LimboHSM
@export var animation_player : AnimationPlayer

func death():
	#print("dying")
	Events.unlock_from.emit()
	actor.state_machine.change_active_state(actor.death)
	actor.hb_collison.disabled=false
	animation_player.play("death")
	await animation_player.animation_finished
	animation_player.play("dead")
	#print("dead")
	
