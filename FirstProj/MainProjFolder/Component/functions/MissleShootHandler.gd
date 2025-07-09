class_name MissileShootHandler

extends Node

@export var missile_list : Dictionary = Projectiles.MISSILES_LIST

@export var turret : Turret
@export var missile = Projectiles.MISSILE_TRACKER

@export var missile_rotation : float = 90.0 : set = set_missile_rot, get = get_missile_rot
@export var fixed_rot : bool = false
@export var missile_speed : float = 400.0
@export var missile_rot_speed : float = 5
@export var missile_accel : float = 20.0
@export var missile_afterburn : bool = true
@export var active : bool =true

func shoot_missile():
	if not active:
		return
	var bullet_inst = missile.instantiate()
	bullet_inst.set_speed(missile_speed)
	bullet_inst.set_accel(missile_accel)
	bullet_inst.set_rot_speed(missile_rot_speed)
	bullet_inst.tracking_time=1
	#bullet_inst.dir = (turret.player_tracker.target_position).normalized()
	bullet_inst.spawnPos = Vector2(turret.global_position.x, turret.global_position.y)
	if fixed_rot:
		bullet_inst.spawnRot=missile_rotation
		bullet_inst.dir=Vector2.RIGHT.rotated(missile_rotation)
	else:
		bullet_inst.spawnRot = turret.rotation_degrees
		bullet_inst.dir=Vector2.RIGHT.rotated(turret.rotation_degrees)
	#audio_stream_player_2d.play()
	print(bullet_inst.dir)
	
	get_tree().current_scene.add_child(bullet_inst)


func set_missile_rot(value : float) -> void:
	missile_rotation=value
	
func get_missile_rot() -> float:
	return missile_rotation
