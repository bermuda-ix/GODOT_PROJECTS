extends Node2D

@export var SPEED : float = 10 : set = set_speed, get = get_speed

var dir : Vector2 = Vector2.RIGHT
var spawnPos : Vector2
var spawnRot : float = -90
var tracking_rot : float = -90
var tracking_vector : Vector2 = Vector2.UP
var init_dir
var player : PlayerEntity = null
var accel : float = 0
@onready var player_tracker = $AnimatedSprite2D/RayCast2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var tracking_timer = $TrackingTimer
@onready var initial_fire_timer = $InitialFireTimer


var elapsed=0.0

@export var explode = preload("res://Component/explosion.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)
	connect("area_entered", _char_hit)
	player = get_tree().get_first_node_in_group("player")
	#dir=Vector2.UP
	global_position = spawnPos
	#spawnRot = -90
	animated_sprite_2d.rotation=deg_to_rad(spawnRot)
	tracking_rot=animated_sprite_2d.rotation_degrees
	
	init_dir=(player_tracker.to_global(player_tracker.target_position) -player_tracker.to_global(Vector2.ZERO)).normalized()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	if not tracking_timer.is_stopped():
		track_player()
	else:
		accel += 10
	
	
	#print(spawnRot)
	print(dir.normalized())
	#dir=player_tracker.transform.x
	dir=lerp(dir, tracking_vector, delta*3)
	#spawnRot=player_tracker.rotation_degrees
	animated_sprite_2d.rotation = lerp_angle(animated_sprite_2d.rotation, tracking_rot, delta*5)
	
	#dir=position.normalized()
	
	position += (dir * (SPEED +accel) * delta)
	
	
	
func set_speed(value: float):
	SPEED=value

func get_speed() -> float:
	return SPEED


func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()

func _char_hit(hurtbox : HurtBox):
	if hurtbox != null:
		var explode_inst=explode.instantiate()
		explode_inst.global_position=Vector2(position.x, position.y)
		get_tree().current_scene.add_child(explode_inst)
		await get_tree().create_timer(0.1).timeout 
		queue_free()

func _on_area_2d_area_entered(area):
	if area.get_collision_layer() == 128:
		var explode_inst=explode.instantiate()
		explode_inst.global_position=Vector2(position.x, position.y)
		get_tree().current_scene.add_child(explode_inst)
		await get_tree().create_timer(0.01).timeout 
		queue_free()


func _on_area_2d_body_entered(body):
	if body.is_in_group("world"):
		var explode_inst=explode.instantiate()
		explode_inst.global_position=Vector2(position.x, position.y)
		get_tree().current_scene.add_child(explode_inst)
		await get_tree().create_timer(0.01).timeout 
		queue_free()
		
func track_player():
	
	
	var direction_to_player : Vector2 = Vector2(player.position.x, player.position.y+25)\
	- position
	
	
	
	tracking_rot=direction_to_player.angle()
	tracking_vector=direction_to_player.normalized()
	#print(direction_to_player.normalized())
	


func _on_initial_fire_timer_timeout():
	tracking_timer.start()

func drone_release_control() -> String:
	var location="new_jersey"
	var behavior="fuck_around"
	return location
