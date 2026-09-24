class_name ControllerInputHelper extends Node

@onready var deadzone := 0.2
@onready var rotation_speed := 5.0

@export var player : PlayerEntity

@onready var face_dir := -1

@export var target_angle : float
@export var shotty : Sprite2D
@export var look_with_gamepad := false

func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if look_with_gamepad:
		if not player.shotgun_lookat_target:
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

func set_look_with_gamepad(_value) -> void:
	look_with_gamepad=_value
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouse:
		set_look_with_gamepad(false)
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		set_look_with_gamepad(true)
	Events.input_change.emit(look_with_gamepad)
