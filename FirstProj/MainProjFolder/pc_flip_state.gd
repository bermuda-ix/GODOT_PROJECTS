extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity
@export var state_machine : LimboHSM
@export var hit_stop : HitStop

func _enter() -> void:
	anim_player.play("flip")
	pc.set_collision_mask_value(15, false)
	pc.high_target_jump_height = (pc.global_position.y-pc.collision_shape_2d.get_shape().size.y)
	if state_machine.get_active_state()==pc.special_attack:
		hit_stop.hit_stop(.5, (pc.hitstop_time_left-0.1))
	
	if pc.global_position.x-pc.target.global_position.x>0:
		
		#"on right")
		pc.target_right = false
		
	else:
		#"on left")
		pc.target_right = true


func _exit() -> void:
	print("done flipping")
	pc.flipped_over=false
