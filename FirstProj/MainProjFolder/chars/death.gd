class_name Death

extends LimboState

@export var actor : Node2D
@export var animation_player : AnimationPlayer
@export var tree_active : bool = true



func _enter() -> void:
	#actor.state="DEATH"
	actor.velocity.y=0
	actor.hb_collision.set_deferred("disabled", true)
	actor.hurt_box_collision.set_deferred("disabled", true)
	actor.collision_shape_2d.set_deferred("disabled", true)
	actor.set_collision_mask_value(15, true)
	if tree_active:
		actor.bt_player.blackboard.set_var("attack_mode", false)
	

#func _update(delta: float) -> void:
	##print_debug("oof i'm dead sadge")
