class_name Death

extends LimboState

@export var actor : Node2D
@export var animation_player : AnimationPlayer
@export var tree_active : bool = true

func _enter() -> void:
	#actor.state="DEATH"
	Events.camera_shake.emit(3,20)
	if tree_active:
		actor.bt_player.blackboard.set_var("attack_mode", false)
	

#func _update(delta: float) -> void:
	##print("oof i'm dead sadge")
