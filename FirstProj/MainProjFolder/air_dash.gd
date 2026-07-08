extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity
@export var hurt_box : HurtBox
#@export var hurtbox : CollisionShape2D
@export var stagger : Stagger
@export var state_machine : LimboHSM
@export var dodge_buffer : Timer
var dodge_dist : float = 0.0
var counter_dist : float = 0.0
var dodge_speed : float = 1.0

@export  var dodge_velocity := Vector2(100.0, 0)
@export var dodge_pos_start := 0.0
@export var dodge_distance := 100.0
@export var dodge_min_dist := 25.0

func _enter() -> void:
	print_debug("dodging")
	
	anim_player.play("air_dash")
	pc.set_collision_mask_value(15, false)
	#pc.set_collision_layer_value(2, false)
	pc.counter_box_collision.disabled=false
	hurt_box.active=false
	
	if pc.input_axis==0:
		pc.velocity.x=dodge_velocity.x*pc.face_dir
	else:
		pc.velocity.x=dodge_velocity.x*pc.input_axis
	dodge_pos_start=pc.global_position.x
	#dodge_buffer.start(0.5)
	
	

func _update(delta: float) -> void:
	pc.velocity.y=0
	if abs(pc.global_position.x-dodge_pos_start)>dodge_min_dist and\
	Input.is_action_just_released("Dodge"):
		pc.state_machine.dispatch(&"falling")
	elif abs(pc.global_position.x-dodge_pos_start)>dodge_distance:
		pc.state_machine.dispatch(&"falling")


func _exit() -> void:
	pc.velocity.x=0
	pc.counter_box_collision.call_deferred("set_disabled", true)
	pc.set_collision_mask_value(15, true)
	hurt_box.active=true
	dodge_buffer.start(0.5)
	
func dodge_blend():
	var _current_dodge=anim_player.current_animation
	anim_player.play_section_with_markers(_current_dodge, "end")


func _on_air_dash_buffer_timeout() -> void:
	pass # Replace with function body.
