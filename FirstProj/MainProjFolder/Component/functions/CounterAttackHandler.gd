class_name CounterAttackHandler
extends Node

@export var actor : Node2D
@export var jump_handler : JumpHandler
@export var shoot_attack_manager : ShootAttackManager
@export var state_machine : LimboHSM
@export var bt_player : BTPlayer

func _physics_process(delta: float) -> void:
	if actor.player_state == actor.player.States.SPECIAL_ATTACK:
		if state_machine.get_active_state()!=actor.attack:
			if actor.player_state == actor.player.States.FLIP:
				shoot_attack_manager.shoot()
			else:
				#handle_jump(0.5)
				
				if state_machine.get_active_state()==actor.attack:
					state_machine.dispatch(&"jump")
				elif state_machine.get_active_state()==actor.chasing:
					state_machine.dispatch(&"jump")
				
	elif actor.player_state == actor.player.States.FLIP:
		if actor.player_right:
			actor.animated_sprite_2d.scale.x = -1
		else:
			actor.animated_sprite_2d.scale.x = 1
		bt_player.blackboard.set_var("counter_attack", true)
	else:
		bt_player.blackboard.set_var("counter_attack", false)
