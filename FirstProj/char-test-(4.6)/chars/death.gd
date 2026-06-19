class_name Death

extends LimboState

@export var actor : Node2D
@export var animation_player : AnimationPlayer
@export var tree_active : bool = true



func _enter() -> void:
	#actor.state="DEATH"
	#actor.velocity.y=0
	if tree_active:
		actor.bt_player.blackboard.set_var("attack_mode", false)
	

#func _update(delta: float) -> void:
	##print_debug("oof i'm dead sadge")
