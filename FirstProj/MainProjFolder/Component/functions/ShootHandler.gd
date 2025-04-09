class_name ShootHandler
extends Node

@export var actor : Node2D
@export var projectile : PackedScene
@export var turret : Turret

func shoot_bullet():
	var bullet_inst = projectile.instantiate()
	bullet_inst.set_speed(400.0)
	#bullet_inst.set_accel(50.0)
	#bullet_inst.tracking_time=0.01
	if actor.turret.slow_track:
		bullet_inst.dir=actor.turret.direction_to_player
	else:
		bullet_inst.dir = (actor.turret.player_tracker.target_position).normalized()
	bullet_inst.spawnPos = Vector2(actor.turret.global_position.x, actor.turret.global_position.y)
	bullet_inst.spawnRot = actor.player_tracker_pivot.rotation_degrees
	#print(bullet_inst.dir)
	
	actor.get_tree().current_scene.add_child(bullet_inst)
