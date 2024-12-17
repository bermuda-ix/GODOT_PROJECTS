extends Area2D

@export var SPEED : float = 100 : set = set_speed, get = get_speed

var dir : Vector2 = Vector2.RIGHT
var spawnPos : Vector2
var spawnRot : float = 0
var init_dir
var player : PlayerEntity = null
@onready var ray_cast_2d = $AnimatedSprite2D/RayCast2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D



var elapsed=0.0

@export var explode = preload("res://Component/explosion.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)
	connect("area_entered", _char_hit)
	player = get_tree().get_first_node_in_group("player")
	
	#global_position = spawnPos
	rotation_degrees = -90
	spawnRot=270
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	print(rotation, "  ", spawnRot)
	#position += dir * SPEED * delta
	
	animated_sprite_2d.rotation = lerp_angle(animated_sprite_2d.rotation, deg_to_rad(spawnRot), delta*5)
	collision_shape_2d.rotation = lerp_angle(collision_shape_2d.rotation, deg_to_rad(spawnRot), delta*5)
	
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

func _on_area_entered(area):
	if area.get_collision_layer() == 128:
		var explode_inst=explode.instantiate()
		explode_inst.global_position=Vector2(position.x, position.y)
		get_tree().current_scene.add_child(explode_inst)
		await get_tree().create_timer(0.1).timeout 
		queue_free()


func _on_body_entered(body):
	if body.is_in_group("world"):
		var explode_inst=explode.instantiate()
		explode_inst.global_position=Vector2(position.x, position.y)
		get_tree().current_scene.add_child(explode_inst)
		await get_tree().create_timer(0.1).timeout 
		queue_free()
		
