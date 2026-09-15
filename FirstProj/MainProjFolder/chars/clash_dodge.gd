class_name ClashDodge extends LimboState

@export var actor : Node2D
@export var animation_player : AnimationPlayer
@export var anim_name : StringName = "clash_dodge"
@export var dodge_velocity := 150.0
@export var hurt_box_collision : CollisionShape2D


func _enter() -> void:
	hurt_box_collision.set_deferred("disabled", false)
	animation_player.play(anim_name)
	if actor.player_right:
		dodge_velocity*=1
	actor.velocity.x=dodge_velocity
	
func _update(delta: float) -> void:
	actor.velocity.x=lerpf(actor.velocity.x, 0, 0.8*delta)
	print_debug(actor.velocity.x)
	actor.move_and_slide()
	
