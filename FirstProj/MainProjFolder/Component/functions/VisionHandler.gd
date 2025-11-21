class_name VisionHandler
extends Node

@export var actor : Node2D
@export var sm : LimboHSM
@export var csm : LimboHSM
@export var always_on : bool = false
@export var combat_state_active : bool = true
@export var vision_range : int = 200
@export var player_tracking : RayCast2D
@export var bt_active : bool = true
@export var stay_on : bool = false

@onready var player : PlayerEntity

@onready var player_found : bool = false

signal player_sighted
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	player_tracking.target_position = Vector2(vision_range, 0)


func handle_vision():
	if always_on:
		player_found=true
	else:
		if player_tracking.is_colliding():
			
			var collision_result = player_tracking.get_collider()
			if collision_result != player or sm.get_active_state()==actor.death:
				#set_state(current_state, States.GUARD)
				return
			else:
				#actor.set_state(actor.current_state, actor.States.ATTACK)
				sm.dispatch(&"attack_mode")
				
				#chase_timer.start(1)
				if player_found==false:
					player_sighted.emit()
				player_found = true
				
			
		else:
		
			#actor.set_state(actor.current_state, actor.States.IDLE)
			if stay_on:
				sm.dispatch(&"start_chase")
			else:
				sm.dispatch(&"idle_mode")
				player_found = false
		

		
	
	if combat_state_active:
		if csm.get_active_state()==actor.ranged_mode and player_found:
			#actor.set_state(actor.current_state, actor.States.ATTACK)
			sm.dispatch(&"attack_mode")
		elif csm.get_active_state()==actor.melee_mode and player_found:
			if bt_active:
				if actor.bt_player.blackboard.get_var("within_range"):
					#actor.set_state(actor.current_state, actor.States.ATTACK)
					sm.dispatch(&"start_attack")
				else:
					#actor.set_state(actor.current_state, actor.States.CHASE)
					sm.dispatch(&"start_chase")
			else:
				pass
	#player_found = true
