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

@export var face_player_active : bool = true
var direction 

func _physics_process(delta: float) -> void:
	
	
	
	if not active:
		if face_player_active:
			face_player()
		return
		
	else:
		
		direction= actor.global_position - actor.player.global_position
		if face_player_active:
			face_player()
		
		if vision_handler.player_found == true:
			
			if keep_distance:
				move_away(distance_from)
			else:
				move_closer()
				climb_stairs()
				fall_through_platform()
				#print_debug(actor.global_position.x)
		

func set_active(value : bool) -> void:
	active=value
func set_keep_distance(value : bool) -> void:
	keep_distance=value

func face_player() -> void:
	#if not active:
		#return
	#else:
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
	#print_debug("move away")
		
	var dir := actor.to_local(actor.nav_agent.get_next_path_position())
		#actor.h_bar.text=str(actor.health.health, " : ", actor.stagger.stagger, " : vel_x:", actor.velocity.x)
	if abs(dir.x) < value:
		state_machine.dispatch(&"run_and_shoot")
		if abs(dir.x) < value and actor.is_on_floor():
			actor.current_speed = (actor.chase_speed * move_away_speed_scale)
			#if state_machine.get_active_state()!=actor.attack:
				#actor.animated_sprite_2d.scale.x = 1
			#actor.hit_box.scale.x = 1
			#actor.attack_range.scale.x = 1
			print_debug("move away")
		else:
			actor.current_speed = -(actor.chase_speed * move_away_speed_scale)
			#if state_machine.get_active_state()!=actor.attack:
				#actor.animated_sprite_2d.scale.x = -1
			#actor.hit_box.scale.x = -1
			#actor.attack_range.scale.x = -1
			print_debug("move away")
		
	else:
		actor.current_speed=0
		state_machine.dispatch(&"start_shoot")

func move_closer() -> void:
	var dir := actor.to_local(actor.nav_agent.get_next_path_position())
	#print_debug(dir.x)
		#actor.h_bar.text=str(actor.health.health, " : ", actor.stagger.stagger, " : vel_x:", actor.velocity.x)
	if dir.x < 0 and actor.is_on_floor():
		actor.current_speed = -actor.chase_speed
		assert(actor.current_speed<0)
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

func climb_stairs():
	var dir_y := actor.to_local(actor.nav_agent.get_next_path_position()).y
	if actor.global_position.y<dir_y:
		actor.set_collision_mask_value(20, true)
		#if "climb_stairs" in actor:
			#actor.climb_stairs=true
	else:
		actor.set_collision_mask_value(20, false)
		#if "climb_stairs" in actor:
			#actor.climb_stairs=false

func fall_through_platform():
	var dir_y := actor.to_local(actor.nav_agent.get_next_path_position()).y
	if actor.global_position.y>dir_y:
		actor.set_collision_mask_value(27, false)
		#if "fall_through_platform" in actor:
			#actor.fall_through_platform=true
	else:
		actor.set_collision_mask_value(27, true)
		#if "fall_through_platform" in actor:
			#actor.cfall_through_platform=false

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

func apply_gravity(delta : float) -> void:
	if not actor.is_on_floor():
		actor.velocity.y += actor.gravity * delta
