class_name MeleeAttackManager
extends Node

@export var actor : Node2D

func melee_attack():
	if actor.state_machine.get_active_state()==actor.attack:
		pass
	else:
		actor.state_machine.change_active_state(actor.attack)
		#"melee attack")
	actor.animation_player.play("atk"+actor.atk_chain)
	
func melee_counter():
	if actor.state_machine.get_active_state()==actor.attack:
		pass
	else:
		actor.state_machine.change_active_state(actor.attack)
		#print_debug("counter")
	actor.animation_player.play("atk_counter")

#func slam(value: String):
	##pass
	#var slam_type=value.capitalize()
	#match slam_type:
		#"DOWN":
			#actor.slam_vel+=actor.gravity+200

func slam():
	actor.slam_vel=actor.gravity+1000

func blast_attack():
	actor.animation_player.play("blast_attack")
