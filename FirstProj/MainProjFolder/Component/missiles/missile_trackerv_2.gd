extends RigidBody2D

@export var explode = preload("res://Component/explosion.tscn")

@export var SPEED : float = 10 : set = set_speed, get = get_speed
@export var accel : float = 10 : set = set_accel, get = get_accel
@export var delayed_tracking : bool = false
@export var rotation_speed : float = 5.0


var dir : Vector2 = Vector2.RIGHT
var spawnPos : Vector2
var spawnRot : float = -90
var tracking_rot : float = -90
var tracking_vector : Vector2 = Vector2.UP
var init_dir
var player : PlayerEntity = null
var tracking_time : float = 0.5
var initial_time : float = 0.05
var scale_size : float


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_tracker: RayCast2D = $AnimatedSprite2D/RayCast2D
@onready var gpu_particles_2d: GPUParticles2D = $AnimatedSprite2D/GPUParticles2D
@onready var tracking_timer: Timer = $TrackingTimer
@onready var initial_fire_timer: Timer = $InitialFireTimer
@onready var damage : int = 1 : set = set_damage, get = get_damage


# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)
	player = get_tree().get_first_node_in_group("player")
	global_position = spawnPos
	global_rotation_degrees=spawnRot
	print_debug(global_position)
	animated_sprite_2d.global_rotation=deg_to_rad(spawnRot)
	tracking_rot=animated_sprite_2d.global_rotation_degrees
	scale*=scale_size
	dir=(player_tracker.to_global(player_tracker.target_position) -player_tracker.to_global(Vector2.ZERO)).normalized()
	#dir=(Vector2.RIGHT.rotated(global_rotation_degrees)).normalized()

func _process(delta: float) -> void:
	pass
	#print_debug(global_position)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	linear_velocity = (dir *(SPEED +accel))

func _physics_process(delta):
	
	
	if not tracking_timer.is_stopped():
		track_player()
		rotate_missile(delta)
		#animated_sprite_2d.global_rotation_degrees=wrapf(missile_rotation, 0, 360)
		dir=(player_tracker.to_global(player_tracker.target_position) -player_tracker.to_global(Vector2.ZERO)).normalized()
		
	else:
		accel += (accel*.02)
		#dir=dir

	
	#position += (dir * (SPEED +accel) * delta)

func bullet_dodged() -> void:
	set_collision_mask_value(2, false)
	set_collision_mask_value(8, false)
	modulate.a=120
	
func set_angular_vel(_rotation_speed : float) -> void:
	angular_velocity=deg_to_rad(rotation_speed)

func set_damage(value : int) -> void:
	damage=value

func get_damage() -> int:
	return damage

func rotate_missile(delta : float) -> void:
	animated_sprite_2d.global_rotation=rotate_toward(animated_sprite_2d.global_rotation,tracking_rot, deg_to_rad(rotation_speed))

func impact():
	explode_impact()

func hard_impact():
	explode_impact()

func explode_impact():
	var explode_inst=explode.instantiate()
	explode_inst.global_position=Vector2(global_position.x, global_position.y)
	get_tree().current_scene.add_child(explode_inst)
	await get_tree().create_timer(0.01).timeout 
	queue_free()

func track_player():
	
	
	var direction_to_player : Vector2 = Vector2(player.global_position.x, player.global_position.y+5)\
	- global_position
	tracking_rot=direction_to_player.angle()
	tracking_vector=direction_to_player.normalized()
	
func _on_initial_fire_timer_timeout() -> void:
	tracking_timer.start(tracking_time)
	
func set_accel(value: float):
	accel=value
func get_accel() -> float:
	return accel

func set_speed(value: float):
	SPEED=value
func get_speed() -> float:
	return SPEED
	
func set_rot_speed(value: float):
	rotation_speed=value



func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	#pass
	queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("WorldStatic"):
		explode_impact()
