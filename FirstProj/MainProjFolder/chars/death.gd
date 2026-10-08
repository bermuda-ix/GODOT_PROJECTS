class_name Death

extends LimboState

@export var actor : Node2D
@export var animation_player : AnimationPlayer = null
@export var tree_active : bool = true



func _enter() -> void:
	#actor.state="DEATH"
	if animation_player!=null:
		animation_player.play("dead")
	if "hb_collision" in actor:
		actor.hb_collision.set_deferred("disabled", true)
	if "hurt_box_collision" in actor:
		actor.hurt_box_collision.set_deferred("disabled", true)
	
	if not actor.is_in_group("turret_top"):
		actor.collision_shape_2d.set_deferred("disabled", true)
		actor.set_collision_mask_value(15, true)
	if tree_active:
		actor.bt_player.blackboard.set_var("attack_mode", false)
	Events.unlock_from.emit()
	

func _update(delta: float) -> void:
	if actor.is_in_group("turret_top") or actor.get_class()=="StaticBody2D":
		return
	else:
		actor.velocity.x=lerpf(actor.velocity.x, 0, 0.8)
		print_debug(actor.velocity.x)
	animation_player.play("dead")
