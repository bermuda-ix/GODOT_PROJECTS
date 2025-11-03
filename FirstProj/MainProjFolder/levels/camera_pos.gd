class_name camera_position

extends Node2D

@export_category("Camera Shake")
@export var rand_strength :  float = 2 : set=set_rand_strength, get=get_rand_strength
@export var shake_fade : float = 20
@onready var camera_2d: Camera2D = $Camera2D

@export_category("Camera Positions/Zoom")
@export var camera_zoom : float = 1.0
@export var stationary : bool = false
@export var offset : Vector2 = Vector2.ZERO


var rng = RandomNumberGenerator.new()

var shake_strength : float = 0

func _ready() -> void:
	Events.camera_shake.connect(camera_shake)
	camera_2d.zoom*=camera_zoom
	
func _process(delta: float) -> void:
	
	camera_2d.offset=offset
	
	if shake_strength>0:
		shake_strength = lerpf(shake_strength, 0, shake_fade*delta)
		
		camera_2d.offset=randomOffset()

func camera_shake_fixed():
	shake_strength=rand_strength
	
func camera_shake(str : float, fade : float):
	shake_strength=str
	shake_fade=fade
	
func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))

func get_rand_strength() -> float:
	return rand_strength
	
func set_rand_strength(value : float):
	rand_strength=value


func set_cam_smooth(value: bool, _speed: float = 3.0) -> void:
	camera_2d.position_smoothing_enabled=value
	camera_2d.position_smoothing_speed=_speed
