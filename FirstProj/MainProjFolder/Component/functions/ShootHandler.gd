class_name ShootHandler
extends Node

@export var actor : Node2D
@export var player_tracking_active : bool = true
@export var turret : Turret
@onready var manual_rotation : bool = false
@onready var turret_rel_loc : Vector2 : set = set_turr_rel_loc, get = get_turr_rel_loc
@onready var bullet_dir: Vector2 = Vector2.ZERO
@export_category("Spread Shot Properties")
@onready var face_dir := -1
@export var spread_shoot := false
@export var spread_amount : int = 5
@export var spread_cone : float =15.0
@export_category("Bullet Specs")
@export var projectile : PackedScene : set = set_projectile
@export var bullet_scale : float = 1.0
@export var bullet_speed : float = 400.0
@export var bullet_damage : int = 1
@export var bullet_rotation : float = 0.0



@export_category("Missile Specs")
@export var rotation_speed : float = 5.0
@export var bullet_tracking_time : float = 3.0

var turret_order : int =0

func _ready() -> void:
	turret.shoot_bullet.connect(shoot_bullet)

func shoot_bullet():
	var bullet_inst = projectile.instantiate()
	bullet_inst.set_speed(bullet_speed)
	bullet_inst.scale_size=bullet_scale
	if bullet_inst.is_in_group("missile"):
		bullet_inst.set_accel(50.0)
		bullet_inst.tracking_time=bullet_tracking_time
		bullet_inst.rotation_speed=rotation_speed
	
	
	if player_tracking_active:
		if turret.slow_track:
			bullet_inst.dir=turret.direction_to_player
		else:
			
			if spread_shoot:
				bullet_inst.dir=bullet_dir
			else:
				bullet_inst.dir = (turret.player_tracker.target_position).normalized()
	else:
		bullet_inst.dir = actor.bullet_dir
	bullet_inst.spawnPos = Vector2(turret.global_position.x,turret.global_position.y)
	if player_tracking_active:
		bullet_inst.spawnRot = actor.player_tracker_pivot.rotation_degrees
	else:
		if bullet_inst.is_in_group("missile"):
			bullet_inst.spawnRot = actor.global_rotation_degrees
		elif manual_rotation:
			#print_debug(bullet_rotation)
			bullet_inst.spawnRot=bullet_rotation
			#bullet_inst.global_rotation=bullet_rotation
		else:
			#print_debug(turret.global_rotation_degrees)
			bullet_inst.spawnRot = turret.global_rotation_degrees
		#print_debug(bullet_inst.dir)
		
	actor.get_tree().current_scene.add_child(bullet_inst)


func set_projectile(_projectile : PackedScene):
	projectile = _projectile
	
func get_turr_rel_loc() -> Vector2:
	return turret.position
	
func set_turr_rel_loc(value : Vector2) -> void:
	turret.position=value
	
func spread_shot() -> void:
	var _bullet_dirs : Array[int] = gun_cone(spread_amount)
	#Events.remove_ammo.emit()
	#ammo-=1
	manual_rotation=true
	for i in spread_amount:
		bullet_dir = ((turret.player_tracker.target_position).normalized())+(rotation_to_direction(_bullet_dirs[i])*face_dir)
		print_debug((turret.player_tracker.target_position).normalized())
		bullet_rotation = _bullet_dirs[i]
		shoot_bullet()

func gun_cone(spread : int) -> Array[int]:
	var _spread_angle : float = spread_cone/spread
	var _bullet_spawn_angle : float = _spread_angle
	var _bullet_spawn_angles : Array[int]
	for i in spread:
		_bullet_spawn_angles.push_front(_bullet_spawn_angle)
		_bullet_spawn_angle+=_spread_angle
	return _bullet_spawn_angles
	
func rotation_to_direction(_rotation_degrees : int) -> Vector2:
	 # Convert rotation from degrees to radians (skip if already in radians)
	var _rotation_radians = deg_to_rad(_rotation_degrees)
	# Calculate direction vector
	var direction = Vector2(cos(_rotation_radians), sin(_rotation_radians))
	# Normalize the vector (optional, but ensures length = 1)
	direction = direction.normalized()
	return direction
