extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity

func _enter() -> void:
	pc.anim_player.play("wall_stick")
	pc.gravity_active=false

func _update(delta: float) -> void:
	pc.velocity.x=0
	pc.velocity.y=0
	if pc.state_machine.get_active_state()==pc.wall_stick:
		if pc.is_on_floor():
			pc.state_machine.dispatch(&"return_to_idle")
	
	if Input.is_action_just_released("jump"):
		wall_jump(delta)
	#if Input.is_action_just_released("sprint"):
		#pc.state_machine.dispatch(&"fall_off_wall")
	#if Input.is_action_just_pressed("jump"):
		#pc.state_machine.dispatch(&"jump_off_wall")

func _exit() -> void:
	pc.wall_hold = false
	pc.gravity_active=true
	
func wall_jump(_delta : float):
	var _wall_normal = pc.get_wall_normal()
	if Input.is_action_pressed("down"):
		pc.state_machine.dispatch(&"jump_off_wall")
	else:
		pc.velocity.x = move_toward(pc.velocity.x, pc.movement_data.speed * _wall_normal.x * 1.5, pc.movement_data.acceleration*10 * _delta)
		pc.velocity.y = pc.movement_data.jump_velocity
		pc.just_wall_jump = true
		pc.state_machine.dispatch(&"jump_off_wall")
