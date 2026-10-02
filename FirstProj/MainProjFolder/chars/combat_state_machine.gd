extends LimboHSM

@export var actor : Node2D
@export var sm : LimboHSM
@export var ranged_state: ranged
@export var melee_state: melee
@export var bt_player : BTPlayer
@export var active : bool = true
@export var ranged_dist : int = 100
@export var vision_handler : VisionHandler

func _physics_process(delta: float) -> void:
	
	actor.distance=abs(actor.global_position.x-actor.player.global_position.x)
	combat_state_change(actor.distance)
	
	if not active:
		return
	elif sm.get_active_state()==actor.staggered or sm.get_active_state()==actor.idle:
		return
	elif actor.attacking and sm.get_active_state()==actor.chasing:
		return
	else:
		#print_debug(actor.distance)
		var _distance=actor.distance
#		RANGED ATTACK
		
		if get_active_state()==ranged_state:
			#print_debug("ranged")
			if actor.is_on_screen and vision_handler.player_colliding:
				actor.turret.shoot_timer.paused=false
				#combat_state_machine.dispatch(&"ranged_mode")
				sm.dispatch(&"start_attack")
			else:
				if sm.get_active_state()!=actor.chasing:
					sm.dispatch(&"start_chase")
				else:
					pass
			
#		MELEE ATTACK
		else:
			actor.turret.shoot_timer.paused=true
			#combat_state_machine.dispatch(&"melee_mode")
			if bt_player != null:
				if not bt_player.blackboard.get_var("within_range"):
					sm.dispatch(&"start_chase")




func combat_state_change(_distance:float)-> void:
	if _distance>ranged_dist: 
		dispatch(&"ranged_mode")
	else:
		dispatch(&"melee_mode")
