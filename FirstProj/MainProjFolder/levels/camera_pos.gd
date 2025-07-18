class_name camera_position

extends Node2D

@export var rand_strength :  float = 2 : set=set_rand_strength, get=get_rand_strength
@export var shake_fade : float = 20
@onready var camera_2d: Camera2D = $Camera2D

@export var camera_zoom : int
@export var stationary : bool = false


var rng = RandomNumberGenerator.new()

var shake_strength : float = 0

func _ready() -> void:
	Events.camera_shake.connect(camera_shake)

func _process(delta: float) -> void:
	
	
	
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
