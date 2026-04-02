class_name Dodge

extends LimboState

@export var actor : Node2D
@export var bt_player : BTPlayer
@export var animation_player: AnimationPlayer
@export var dodge_anim := "dodge"
@export var _velocity_x := 0.0
@export var _velocity_y := 0.0
@onready var face_dir := 1

func _enter() -> void:
	#print_debug("begin dodge")
	animation_player.play(dodge_anim)
	actor.dodge_timer.start()
	actor.hurt_box_collision.disabled=true
	actor.hb_collision.disabled=true
	print_debug(_velocity_x)
	if actor.player_right:
		face_dir=1
	else:
		face_dir=-1
	_velocity_x=_velocity_x*face_dir
	print_debug(_velocity_x)

func _update(delta: float) -> void:
	print_debug(actor.velocity.x)
	print_debug(_velocity_x)
	actor.velocity.x=_velocity_x
	actor.velocity.y=_velocity_y

func _exit() -> void:
	animation_player.stop()
	actor.hurt_box_collision.disabled=false

func dodge_setup(_vel_x :=0 , _vel_y :=0):
	_velocity_x=_vel_x
	_velocity_y=_vel_y
