extends Area2D

@export var SPEED : float = 100 : set = set_speed, get = get_speed

var dir : Vector2 = Vector2.RIGHT
var spawnPos : Vector2
var spawnRot : float


# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)
	connect("area_entered", _char_hit)

	
	global_position = spawnPos
	global_rotation = spawnRot



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	position += dir * SPEED * delta
	rotation = spawnRot
	
	
func set_speed(value: float):
	SPEED=value

func get_speed() -> float:
	return SPEED


func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()

func _char_hit(hurtbox : HurtBox):
	if hurtbox != null:
		queue_free()

func _on_area_entered(area):
	if area.get_collision_layer() == 128:
		queue_free()
