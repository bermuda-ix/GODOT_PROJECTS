extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity
@export var hurtbox : CollisionShape2D
var dodge_dist : float = 0.0
var counter_dist : float = 0.0
var dodge_speed : float = 1.0

func _enter() -> void:
	print_debug("dodging")
	anim_player.play(pc.dodge_anim_run)
	pc.set_collision_mask_value(15, false)
	pc.counter_box_collision.disabled=false
	hurtbox.disabled=true
	if pc.input_axis==0:
		dodge_dist=pc.global_position.x+30*pc.face_dir
		dodge_speed=7
	else:
		dodge_dist=pc.global_position.x+70*pc.input_axis
		dodge_speed=5
	counter_dist = pc.global_position.x-10*pc.face_dir
	
	

func _update(delta: float) -> void:
	pc.global_position.x=lerpf(pc.global_position.x, dodge_dist, dodge_speed*delta)
	#if pc.input_axis==0:
		#pc.global_position.x=lerpf(pc.global_position.x, dodge_dist, 0.2)
	

func _exit() -> void:
	pc.velocity.x=0
	#pc.counter_box_collision.disabled=true
	pc.counter_box_collision.call_deferred("set_disabled", true)
	hurtbox.call_deferred("set_disabled", false)
	#hurtbox.disabled=false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name==pc.dodge_anim_run:
		pc.state_machine.dispatch(&"return_to_idle")
		pc.set_collision_mask_value(15, true)
