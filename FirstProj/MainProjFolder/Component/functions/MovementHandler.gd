class_name MovementHandler
extends Node

@export var actor : Node2D
@export var active : bool = true

func _physics_process(delta: float) -> void:
	
	var direction= actor.global_position - actor.player.global_position
	if not active:
		return
	
	if actor.player_found == true:
		
		var dir = actor.to_local(actor.nav_agent.get_next_path_position())
		if dir.x > 0 and actor.is_on_floor():
			actor.current_speed = actor.chase_speed
			actor.animated_sprite_2d.scale.x = -1
			actor.hit_box.scale.x = -1
		else:
			actor.current_speed = -actor.chase_speed
			actor.animated_sprite_2d.scale.x = 1
			actor.hit_box.scale.x = 1
