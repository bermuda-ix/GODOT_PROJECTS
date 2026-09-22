extends LimboState
@export var pc : PlayerEntity
@export var anim_player : AnimationPlayer
@export var shotty_anim_player : AnimationPlayer
@export var aim_speed_scale := 1.0
@export var aim_speed_end : int = 50
@export var clash_power: ClashPower

func _enter() -> void:
	shotty_anim_player.speed_scale=aim_speed_scale+(clash_power.clash_power/2)
	shotty_anim_player.play("shotgun_aim")
	pc.aim_speed=pc.movement_data.speed
	if Input.is_action_pressed("sprint"):
		pc.shotty_target=pc.find_closest_enemy()
		pc.shotgun_point_to_target()

func _update(delta: float) -> void:
	pc.aim_speed=lerpf(pc.aim_speed, aim_speed_end, 0.05)
	if pc.is_on_floor():
		if Input.is_action_just_pressed("walk_left") or Input.is_action_just_pressed("walk_right"):
			anim_player.play("walk")
		elif Input.is_action_just_released("walk_left") or Input.is_action_just_released("walk_right"):
			anim_player.play("idle")
	else:
		anim_player.play("crouch_gun")
	
	if Input.is_action_pressed("lockon"):
		pc.shotty_target=pc.find_closest_enemy()
		pc.shotgun_point_to_target()
	elif Input.is_action_just_released("lockon"):
		if pc.target==null:
			pc.set_shotgun_target_look(false)
		else:
			pass
	if not Input.is_action_pressed("special_attack"):
		pc.state_machine.dispatch(&"shoot")

func _exit() -> void:
	shotty_anim_player.pause()
	shotty_anim_player.speed_scale=1
	pc.aim_speed=pc.movement_data.speed
