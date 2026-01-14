class_name ShootHandler
extends Node

@export var actor : Node2D
@export var player_tracking_active : bool = true
@export var turret : Turret
@onready var turret_rel_loc : Vector2 : set = set_turr_rel_loc, get = get_turr_rel_loc
@export_category("Bullet Specs")
@export var projectile : PackedScene : set = set_projectile

@export var bullet_scale : float = 1.0

@export var bullet_speed : float = 400.0



var turret_order : int =0

func shoot_bullet():
	var bullet_inst = projectile.instantiate()
	bullet_inst.set_speed(bullet_speed)
	bullet_inst.scale_size*=bullet_scale
	#bullet_inst.set_accel(50.0)
	#bullet_inst.tracking_time=0.01
	if player_tracking_active:
		if turret.slow_track:
			bullet_inst.dir=turret.direction_to_player
		else:
			bullet_inst.dir = (turret.player_tracker.target_position).normalized()
	else:
		bullet_inst.dir = actor.bullet_dir
	bullet_inst.spawnPos = Vector2(turret.global_position.x,turret.global_position.y)
	if player_tracking_active:
		bullet_inst.spawnRot = actor.player_tracker_pivot.rotation_degrees
	else:
		bullet_inst.spawnRot = actor.bullet_dir.angle()
		#print(bullet_inst.dir)
		
	actor.get_tree().current_scene.add_child(bullet_inst)

func set_projectile(_projectile : PackedScene):
	projectile = _projectile
	
func get_turr_rel_loc() -> Vector2:
	return turret.position
	
func set_turr_rel_loc(value : Vector2) -> void:
	turret.position=value
