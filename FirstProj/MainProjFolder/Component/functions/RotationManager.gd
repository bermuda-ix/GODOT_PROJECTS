class_name RotationManager
extends Node

@export var actor : Node2D
@export var rotation_speed : int = 0
@export var active : bool = true
@export var state_machine : LimboHSM
@export var min_arc : float
@export var max_arc : float

var elapsed : float = 0.0

func _physics_process(delta: float) -> void:
	
	if not active:
		return
	elif state_machine.get_active_state()==actor.idle:
		actor.sprite_2d.rotation_degrees=min_arc
		actor.turret_top.rotation_degrees=-180
	else:
		if actor.sprite_2d.global_rotation_degrees != actor.player_tracker_pivot.global_rotation_degrees:
			#if state_machine.get_active_state()==actor.attack:
				#print(actor.sprite_2d.rotation_degrees, " ",abs(actor.sprite_2d.rotation_degrees-actor.player_tracker_pivot.rotation_degrees))
			
				#actor.sprite_2d.global_rotation_degrees = actor.player_tracker_pivot.global_rotation_degrees
			if actor.player_tracker_pivot.rotation_degrees >= min_arc and actor.player_tracker_pivot.rotation_degrees <= max_arc:
				if rotation_speed==0:
					actor.sprite_2d.rotation_degrees = actor.player_tracker_pivot.rotation_degrees
				else:
					if abs(actor.sprite_2d.rotation_degrees-actor.player_tracker_pivot.rotation_degrees)<=rotation_speed+3:
						pass
					elif round(actor.sprite_2d.rotation_degrees) < round(actor.player_tracker_pivot.rotation_degrees):
						actor.sprite_2d.rotation_degrees += rotation_speed
					elif round(actor.sprite_2d.rotation_degrees) > round(actor.player_tracker_pivot.rotation_degrees):
						actor.sprite_2d.rotation_degrees -= rotation_speed
					else:
						pass
			elif actor.player_tracker_pivot.rotation_degrees > max_arc:
				if rotation_speed == 0:
					actor.sprite_2d.rotation_degrees = max_arc
				else:
					actor.sprite_2d.rotation_degrees=rad_to_deg(lerp_angle(actor.sprite_2d.rotation, deg_to_rad(max_arc), 0.01))
					elapsed +=delta
			elif actor.player_tracker_pivot.rotation_degrees < min_arc:
				if rotation_speed== 0:
					actor.sprite_2d.rotation_degrees = min_arc
				else:
					actor.sprite_2d.rotation_degrees=rad_to_deg(lerp_angle(actor.sprite_2d.rotation, deg_to_rad(min_arc), 0.01))
					elapsed +=delta
		else:
			return
	if actor.turret.slow_track:
		actor.turret.direction_to_player=Vector2.RIGHT.rotated(actor.sprite_2d.rotation)
		print(actor.turret.direction_to_player)
