class_name CounterAttackHandler
extends Node

@export var actor : Node2D
@export var jump_handler : JumpHandler
@export var shoot_attack_manager : ShootAttackManager
@export var state_machine : LimboHSM

func counter_attack():
	if actor.player_state == actor.player.States.SPECIAL_ATTACK:
		#"jump")
		if state_machine.get_active_state()!=actor.attack:
			if actor.player_state == actor.player.States.FLIP:
				shoot_attack_manager.shoot()
			else:
				#handle_jump(0.5)
				jump_handler.handle_jump(0.5)
				
