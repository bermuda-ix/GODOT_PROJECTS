class_name MovementHandler
extends Node

@export var actor : Node2D
@export var active : bool = true
@export var state_machine : LimboHSM
@export var vision_handler : VisionHandler

func _physics_process(delta: float) -> void:
	
	var direction= actor.global_position - actor.player.global_position
	if not active:
		return
	
	if vision_handler.player_found == true:
		
		var dir = actor.to_local(actor.nav_agent.get_next_path_position())
		#actor.h_bar.text=str(actor.health.health, " : ", actor.stagger.stagger, " : vel_x:", actor.velocity.x)
		if dir.x > 0 and actor.is_on_floor():
			actor.current_speed = actor.chase_speed
			if state_machine.get_active_state()!=actor.attack:
				actor.animated_sprite_2d.scale.x = -1
			actor.hit_box.scale.x = -1
		else:
			actor.current_speed = -actor.chase_speed
			if state_machine.get_active_state()!=actor.attack:
				actor.animated_sprite_2d.scale.x = 1
			actor.hit_box.scale.x = 1
