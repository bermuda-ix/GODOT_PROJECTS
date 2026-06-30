extends RigidBody2D

const BULLET_IMPACT = preload("res://Component/projectiles/bullet_impact.tscn")
@export var SPEED : float = 100 : set = set_speed, get = get_speed
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

@onready var projectile_hitbox: ProjectileHitBox = $ProjectileHitbox



var dir : Vector2 = Vector2.RIGHT
var spawnPos : Vector2
var spawnRot : float
var scale_size : float


# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)
	#shoot_range()
	global_position = spawnPos
	global_rotation = spawnRot
	linear_velocity=(dir*SPEED)
	scale=Vector2(scale_size, scale_size)
	print_debug(scale)
	modulate.a=255
	sleeping=true



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += dir * SPEED * delta
	print_debug(position)
	rotation = spawnRot

	
	
func set_speed(value: float):
	SPEED=value

func get_speed() -> float:
	return SPEED

func set_damage(value : int) -> void:
	projectile_hitbox.damage=value

func get_damage() -> int:
	return projectile_hitbox.damage

func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()

func _char_hit(hurtbox : HurtBox):
	if hurtbox != null or hurtbox.active:
		#AudioStreamManager.play(SoundFx.SOCAPE_SMALL_KNOCK)
		impact()
		

func _on_area_entered(area):
	#if area.is_in_group("shield"):
		#impact()
		#AudioStreamManager.play(SoundFx.SOCAPE_SMALL_KNOCK)
	impact()

func impact() -> void:
	var impact_fx=BULLET_IMPACT.instantiate()
	impact_fx.global_position=Vector2(position.x, position.y)
	get_tree().current_scene.add_child(impact_fx)
	audio_stream_player_2d.play(0.15)
	set_physics_process(false)
	#queue_free()
	
func hard_impact():
	#AudioStreamManager.play(SoundFx.SOCAPE_SMALL_KNOCK)
	impact()


func bullet_dodged() -> void:
	set_collision_mask_value(2, false)
	set_collision_mask_value(8, false)
	modulate.a=120

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_body_entered(body: Node) -> void:
	#print_debug("use on body entered")
	if body.is_in_group("WorldStatic"):
		impact()


func _on_area_2d_area_entered(area: Area2D) -> void:

	if area.is_in_group("player_hurtbox"):
		impact()
		#AudioStreamManager.play(SoundFx.SOCAPE_SMALL_KNOCK)
	#else:
		#AudioStreamManager.play(SoundFx.SOCAPE_SMALL_KNOCK)
		#if area.is_in_group("regular_enemy_hb") or area.is_in_group("player_hurtbox"):
			#if "active" in area:
				#if not area.active:
					#return
				#else:
					#if "bullet_impact" in area:
						#area.bullet_impact(1)
					#impact()


func _on_audio_stream_player_2d_finished() -> void:
	queue_free()
