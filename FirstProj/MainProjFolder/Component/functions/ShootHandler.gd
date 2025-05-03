class_name ShootHandler
extends Node

@export var actor : Node2D
@export var projectile : PackedScene : set = set_projectile
@export var turrets : Array[Turret]
var turret_order : int =0

func shoot_bullet():
	if turrets.size()<=1:
		var bullet_inst = projectile.instantiate()
		bullet_inst.set_speed(400.0)
		#bullet_inst.set_accel(50.0)
		#bullet_inst.tracking_time=0.01
		if turrets[0].slow_track:
			bullet_inst.dir=turrets[0].direction_to_player
		else:
			bullet_inst.dir = (turrets[0].player_tracker.target_position).normalized()
		bullet_inst.spawnPos = Vector2(turrets[0].global_position.x,turrets[0].global_position.y)
		bullet_inst.spawnRot = actor.player_tracker_pivot.rotation_degrees
		#print(bullet_inst.dir)
		
		actor.get_tree().current_scene.add_child(bullet_inst)

func set_projectile(_projectile : PackedScene):
	projectile = _projectile
	
