class_name RotationManager
extends Node

@export var actor : Node2D
@export var rotation_speed : int = 0
@export var active : bool = true
@export var state_machine : LimboHSM
@export var min_arc : float
@export var max_arc : float

func _physics_process(delta: float) -> void:
	
	if not active:
		return
	elif state_machine.get_active_state()==actor.idle:
		actor.sprite_2d.rotation_degrees=-220
		actor.turret_top.rotation_degrees=-180
	else:
		if actor.sprite_2d.global_rotation_degrees != actor.player_tracker_pivot.global_rotation_degrees:
			print(actor.sprite_2d.rotation_degrees, " ",actor.sprite_2d.global_rotation_degrees)
			if rotation_speed==0:
				actor.sprite_2d.global_rotation_degrees = actor.player_tracker_pivot.global_rotation_degrees
		else:
			return
