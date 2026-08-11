extends RigidBody2D

const BULLET_IMPACT = preload("res://Component/projectiles/bullet_impact.tscn")
@export var SPEED : float = 100 : set = set_speed, get = get_speed
@onready var damage : int = 1 : set = set_damage, get = get_damage



@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var gpu_particles_2d: GPUParticles2D = $Sprite2D/GPUParticles2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

var dir : Vector2 = Vector2.RIGHT
var spawnPos : Vector2
var spawnRot : float
var scale_size : float 


# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)
	#shoot_range()
	gpu_particles_2d.emitting=true
	global_position = spawnPos
	sprite_2d.rotation_degrees=spawnRot
	
	#print_debug(sprite_2d.rotation_degrees)
	#print_debug(spawnRot)
	
	scale*=scale_size



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += dir * SPEED * delta
	#global_rotation = spawnRot


	
	
func set_speed(value: float):
	SPEED=value

func get_speed() -> float:
	return SPEED


func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()
		

func _on_area_entered(area):
	pass

func hard_impact():
	#AudioStreamManager.play(SoundFx.SOCAPE_SMALL_KNOCK)
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
	audio_stream_player_2d.play(0.15)
	set_physics_process(false)
	queue_free()

func set_damage(value : int) -> void:
	damage=value

func get_damage() -> int:
	return damage

func set_stagger_damage(value : int) -> void:
	damage=value

func get_stagger_damage() -> int:
	return damage

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("WorldStatic"):
		hard_impact()
	elif body.is_in_group("player"):
		if body.state_machine.get_active_state()==body.dodge_state:
			return
		else:
			impact()
	else:
		impact()

func bullet_dodged() -> void:
	set_collision_mask_value(2, false)
	set_collision_mask_value(8, false)
	modulate.a=120

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("shield"):
		impact()
		AudioStreamManager.play(SoundFx.SOCAPE_SMALL_KNOCK)
	else:
		#AudioStreamManager.play(SoundFx.SOCAPE_SMALL_KNOCK)
		pass


func _on_audio_stream_player_2d_finished() -> void:
	queue_free()


func _on_projectile_hit_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox") and area.active:
		if "bullet_impact" in area:
			area.bullet_impact(1)
		impact()
