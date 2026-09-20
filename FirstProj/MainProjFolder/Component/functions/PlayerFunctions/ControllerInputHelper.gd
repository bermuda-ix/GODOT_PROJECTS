class_name ControllerInputHelper extends Node

@onready var deadzone := 0.2
@onready var rotation_speed := 5.0

@export var player : PlayerEntity

@onready var face_dir := -1

@export var target_angle : float
@export var shotty : Sprite2D
@export var look_with_gamepad := false


func _physics_process(delta: float) -> void:
	if look_with_gamepad:
		shotty.rotation=gun_rotate()
	
	if player.animated_sprite_2d.scale.x==-1:
		face_dir=-1
	else:
		face_dir=1

func gun_rotate() -> float:
	var _input_vect := Vector2(
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_X) * face_dir,
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	)
	
	if _input_vect.length() >= deadzone:
		target_angle = _input_vect.angle()
	
	return target_angle
