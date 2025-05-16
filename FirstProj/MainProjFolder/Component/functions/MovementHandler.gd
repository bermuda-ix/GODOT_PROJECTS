class_name MovementHandler
extends Node

@export var actor : Node2D
@export var active : bool = true : set = set_active
@export var state_machine : LimboHSM
@export var vision_handler : VisionHandler
@export var keep_distance : bool = false : set = set_keep_distance
@export var distance_from : int = 150
@export var move_away_speed_scale : float = .8
@export var air_turn : bool = true

func _physics_process(delta: float) -> void:
	
	var direction= actor.global_position - actor.player.global_position
	
	if not active:
		return
		
	else:
		face_player()
		if vision_handler.player_found == true:
			
			if keep_distance:
				move_away(distance_from)
			else:
				move_closer()
		

func set_active(value : bool) -> void:
	active=value
func set_keep_distance(value : bool) -> void:
	keep_distance=value

func face_player() -> void:
	if not actor.player_right:
		if state_machine.get_active_state()!=actor.attack:
			actor.animated_sprite_2d.scale.x = 1
		actor.hit_box.scale.x = 1
		actor.attack_range.scale.x = 1
		
	else:
		if state_machine.get_active_state()!=actor.attack:
			actor.animated_sprite_2d.scale.x = -1
		actor.hit_box.scale.x = -1
		actor.attack_range.scale.x = -1

	
func move_away(value : int) -> void:
	#print("move away")
		
	var dir = actor.to_local(actor.nav_agent.get_next_path_position())
		#actor.h_bar.text=str(actor.health.health, " : ", actor.stagger.stagger, " : vel_x:", actor.velocity.x)
	if abs(dir.x) < value:
		state_machine.dispatch(&"run_and_shoot")
		if abs(dir.x) < value and actor.is_on_floor():
			actor.current_speed = (actor.chase_speed * move_away_speed_scale)
			#if state_machine.get_active_state()!=actor.attack:
				#actor.animated_sprite_2d.scale.x = 1
			#actor.hit_box.scale.x = 1
			#actor.attack_range.scale.x = 1
			print("move away")
		else:
			actor.current_speed = -(actor.chase_speed * move_away_speed_scale)
			#if state_machine.get_active_state()!=actor.attack:
				#actor.animated_sprite_2d.scale.x = -1
			#actor.hit_box.scale.x = -1
			#actor.attack_range.scale.x = -1
			print("move away")
		
	else:
		actor.current_speed=0
		state_machine.dispatch(&"start_shoot")

func move_closer() -> void:
	var dir = actor.to_local(actor.nav_agent.get_next_path_position())
		#actor.h_bar.text=str(actor.health.health, " : ", actor.stagger.stagger, " : vel_x:", actor.velocity.x)
	if dir.x < 0 and actor.is_on_floor():
		actor.current_speed = -actor.chase_speed
		#if state_machine.get_active_state()!=actor.attack:
			#actor.animated_sprite_2d.scale.x = -1
		#actor.hit_box.scale.x = -1
		#actor.attack_range.scale.x = -1
	else:
		actor.current_speed = actor.chase_speed
		#if state_machine.get_active_state()!=actor.attack:
			#actor.animated_sprite_2d.scale.x = 1
		#actor.hit_box.scale.x = 1
		#actor.attack_range.scale.x = 1

func knockback_set(value_x : int, value_y : int) -> void:
	if actor.player_right:
		value_x*=1
	else:
		value_x*=-1
	actor.knockback=Vector2(value_x,value_y)

func cutscene_move(dir : int , speed : float):
	dir = clampi(dir, -1, 1)
	if dir==1:
		actor.current_speed  = speed
	elif dir==-1:
		actor.current_speed  = -speed
	else:
		actor.current_speed=0
