class_name MeleeAttackManager
extends Node

@export var actor : Node2D

func melee_attack():
	actor.state_machine.change_active_state(actor.attack)
	#"melee attack")
	actor.animation_player.play("atk"+actor.atk_chain)
