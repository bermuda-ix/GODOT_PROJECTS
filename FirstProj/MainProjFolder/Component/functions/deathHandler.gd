class_name DeathHandler
extends Node

@export var actor: Node2D
@export var sm : LimboHSM
@export var animation_player : AnimationPlayer
@export var tree_active : bool = true
@export var health : Health
@export var death_state : LimboState

#Scoring variables
@export var score : int = 3
@export var heat_value_inc : int = 1

func _ready() -> void:
	if health.health<=0:
		queue_free()

func death():
	#print_debug("dying")
	Events.unlock_from.emit()
	#actor.parry_timer.stop()
	Events.inc_score.emit(score)
	Events.increase_heat_gauge.emit(heat_value_inc)
	
	if tree_active:
		actor.bt_player.blackboard.set_var("attack_mode", false)
		actor.bt_player.restart()
	#actor.hit_stop.hit_stop(0.05,5)
	sm.dispatch(&"die")
	
	#print_debug("dead")
func dying():
	actor.move_and_slide()
	if actor.is_on_floor() and not actor.jump_timer.is_stopped():
		actor.dying.blackboard.set_var("hit_the_floor", true)
	actor.velocity.x=actor.knockback.x
	

func dead():
	pass
	
