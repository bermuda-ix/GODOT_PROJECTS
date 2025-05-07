class_name ShootHandler
extends Node

@export var actor : Node2D
@export var projectile : PackedScene : set = set_projectile
@export var turret : Turret
@onready var turret_rel_loc : Vector2 : set = set_turr_rel_loc, get = get_turr_rel_loc
var turret_order : int =0

func shoot_bullet():
	var bullet_inst = projectile.instantiate()
	bullet_inst.set_speed(400.0)
	#bullet_inst.set_accel(50.0)
	#bullet_inst.tracking_time=0.01
	if turret.slow_track:
		bullet_inst.dir=turret.direction_to_player
	else:
		bullet_inst.dir = (turret.player_tracker.target_position).normalized()
	bullet_inst.spawnPos = Vector2(turret.global_position.x,turret.global_position.y)
	bullet_inst.spawnRot = actor.player_tracker_pivot.rotation_degrees
		#print(bullet_inst.dir)
		
	actor.get_tree().current_scene.add_child(bullet_inst)

func set_projectile(_projectile : PackedScene):
	projectile = _projectile
	
func get_turr_rel_loc() -> Vector2:
	return turret.position
	
func set_turr_rel_loc(value : Vector2) -> void:
	turret.position=value
