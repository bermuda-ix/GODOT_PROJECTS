extends RigidBody2D

const BULLET_IMPACT = preload("res://Component/projectiles/bullet_impact.tscn")
@export var SPEED : float = 100 : set = set_speed, get = get_speed


@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D

var dir : Vector2 = Vector2.RIGHT
var spawnPos : Vector2
var spawnRot : float


# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)
	connect("area_entered", _char_hit)
	#shoot_range()
	gpu_particles_2d.emitting=true
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
		AudioStreamManager.play(SoundFx.SOCAPE_SMALL_KNOCK)
		impact()
		

func _on_area_entered(area):
	if area.is_in_group("shield"):
		#impact()
		AudioStreamManager.play(SoundFx.SOCAPE_SMALL_KNOCK)
	impact()


func hard_impact():
	AudioStreamManager.play(SoundFx.SOCAPE_SMALL_KNOCK)
	impact()
#func shoot_range():
	#var _area2ds = get_overlapping_areas()
	#var _area_name : Array[String]
	#_area_name.resize(_area2ds.size())
	#for i in range(_area2ds.size()):
		#_area_name[i]=_area2ds[i].name
	#if not _area_name.has("SpAtkHitBox"):
		#queue_free()

func impact() -> void:
	var impact_fx=BULLET_IMPACT.instantiate()
	impact_fx.global_position=Vector2(position.x, position.y)
	get_tree().current_scene.add_child(impact_fx)
	queue_free()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("WorldStatic"):
		hard_impact()
