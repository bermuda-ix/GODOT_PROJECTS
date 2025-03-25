class_name VisionHandler
extends Node

@export var actor : Node2D
@export var sm : LimboHSM
@export var csm : LimboHSM


func handle_vision():
	if actor.player_tracking.is_colliding():
		var collision_result = actor.player_tracking.get_collider()
		
		if collision_result != actor.player or sm.get_active_state()==actor.death:
			#set_state(current_state, States.GUARD)
			return
		else:
			#actor.set_state(actor.current_state, actor.States.ATTACK)
			sm.dispatch(&"attack_mode")
			
			#chase_timer.start(1)
			actor.player_found = true
			
	else:
		
		#actor.set_state(actor.current_state, actor.States.IDLE)
		sm.dispatch(&"idle_mode")
		actor.player_found = false
		
	if not actor.attack_range.has_overlapping_bodies():
		actor.bt_player.blackboard.set_var("within_range", false)
		
	if csm.get_active_state()==actor.ranged and actor.player_found:
		#actor.set_state(actor.current_state, actor.States.ATTACK)
		sm.dispatch(&"attack_mode")
	elif csm.get_active_state()==actor.melee:
		if actor.bt_player.blackboard.get_var("within_range"):
			#actor.set_state(actor.current_state, actor.States.ATTACK)
			sm.dispatch(&"start_attack")
		else:
			#actor.set_state(actor.current_state, actor.States.CHASE)
			sm.dispatch(&"start_chase")
			#chase_timer.start(1)
	#player_found = true
