class_name DeathHandler
extends Node

@export var actor: Node2D
@export var sm : LimboHSM

func death():
	print("dying")
	actor.state_machine.change_active_state(actor.death)
	actor.hb_collison.disabled=false
	actor.animation_player.play("death")
	await actor.animation_player.animation_finished
	
