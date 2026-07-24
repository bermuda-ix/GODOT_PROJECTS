class_name VisionHandler
extends Node

@export var actor : Node2D
@export var sm : LimboHSM
@export var csm : LimboHSM
@export var always_on : bool = false
@export var active : bool = true
@export var combat_state_active : bool = true
@export var vision_range : int = 200
@export var player_tracking : RayCast2D
@export var bt_active : bool = true
@export var stay_on : bool = false
@export var nav_agent : NavigationAgent2D

@onready var player : PlayerEntity
@onready var player_colliding := false

@onready var player_found : bool = false

signal player_sighted
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	player_tracking.target_position = Vector2(vision_range, 0)
	

func get_player_relative_loc():
	if player.global_position.x>actor.global_position.x:
		actor.player_right=true
	else:
		actor.player_right=false
		

func handle_vision():
	player_colliding=player_tracking.is_colliding()
	if not active:
		return
	if always_on:
		player_found=true
		#sm.dispatch(&"start_chase")
	elif not path_valid():
		player_found=false
	else:
		#actor.player_colliding=player_tracking.is_colliding()
		if player_tracking.is_colliding():
			#print_debug(player_tracking.get_collider())
			
			var collision_result = player_tracking.get_collider()
			if collision_result != player:
				#set_state(current_state, States.GUARD)
				return
			else:
				if sm.get_active_state()==actor.death:
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
			if actor.is_on_screen:
				sm.dispatch(&"attack_mode")
			else:
				sm.dispatch(&"start_chase")
		elif csm.get_active_state()==actor.melee_mode and player_found:
			if bt_active:
				if actor.bt_player.blackboard.get_var("within_range"):
					#actor.set_state(actor.current_state, actor.States.ATTACK)
					sm.dispatch(&"start_attack")
				else:
					#actor.set_state(actor.current_state, actor.States.CHASE)
					if actor.attacking==false:
						sm.dispatch(&"start_chase")
					else:
						return
			else:
				pass
	#player_found = true

func path_valid() -> bool:
	if nav_agent==null:
		return false
	return nav_agent.is_target_reachable()
