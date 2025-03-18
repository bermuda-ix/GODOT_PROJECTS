class_name CombatStateChangeHandler

extends Node

@export var actor : Node2D
@export var combat_state_machine: LimboHSM
@export var active : bool = true

func _physics_process(delta: float) -> void:
	if not active:
		return
	else:
		actor.distance=abs(actor.global_position.x-actor.player.global_position.x)
		#print(actor.distance)
		if actor.distance>100:
			#print("ranged")
			actor.turret.shoot_timer.paused=false
			combat_state_machine.dispatch(&"ranged_mode")
			
		else:
			#print("melee")
			actor.turret.shoot_timer.paused=true
			combat_state_machine.dispatch(&"melee_mode")
		
