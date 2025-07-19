class_name DeathHandler
extends Node

@export var actor: Node2D
@export var sm : LimboHSM
@export var animation_player : AnimationPlayer
@export var tree_active : bool = true


func death():
	#print("dying")
	Events.unlock_from.emit()
	#actor.parry_timer.stop()
	Events.inc_score.emit()
	if tree_active:
		actor.bt_player.blackboard.set_var("attack_mode", false)
		actor.bt_player.restart()
	#actor.hit_stop.hit_stop(0.05,5)
	sm.dispatch(&"die")
	
	#print("dead")
func dying():
	actor.move_and_slide()
	if actor.is_on_floor() and not actor.jump_timer.is_stopped():
		actor.dying.blackboard.set_var("hit_the_floor", true)
	actor.velocity.x=actor.knockback.x

func dead():
	pass
	
