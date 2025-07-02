extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity
@export var hit_stop : HitStop
@onready var parry_success_state: LimboHSM = $".."


func _enter() -> void:
	print("how do you pronouce riposte")
	anim_player.play("dodge_back")
	hit_stop.end_hit_stop()
	pc.set_collision_mask_value(15, false)
	
func _update(delta: float) -> void:
	if pc.animated_sprite_2d.scale.x<0:
		#pc.velocity.x = move_toward(pc.velocity.x, pc.movement_data.speed*2, pc.movement_data.acceleration*20 * delta)
		pc.velocity.x=pc.movement_data.dodge_speed
	else:
		#pc.velocity.x = move_toward(pc.velocity.x, pc.movement_data.speed*2, pc.movement_data.acceleration*20 * delta)
		pc.velocity.x=pc.movement_data.dodge_speed*-1

func _exit() -> void:
	pc.velocity.x=0

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="dodge_back":
		pc.state_machine.dispatch(&"return_from_parry")
		pc.set_collision_mask_value(15, true)
