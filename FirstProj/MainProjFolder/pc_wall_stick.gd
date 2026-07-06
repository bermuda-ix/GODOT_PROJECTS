extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity

func _enter() -> void:
	pc.anim_player.play("wall_stick")

func _update(delta: float) -> void:
	pc.velocity.x=0
	if pc.state_machine.get_active_state()==pc.wall_stick:
		if pc.is_on_floor():
			pc.state_machine.dispatch(&"return_to_idle")
	
	if Input.is_action_just_released("sprint"):
		pc.state_machine.dispatch(&"fall_off_wall")
	if Input.is_action_just_pressed("jump"):
		pc.state_machine.dispatch(&"jump_off_wall")

func _exit() -> void:
	pc.wall_hold = false
