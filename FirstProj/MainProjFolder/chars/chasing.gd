class_name Chasing

extends LimboState

@export var actor : Node2D
@export var bt_player : BTPlayer
@export var chase_speed : float = 40
@export var run_anim = "run"

func _enter() -> void:
	actor.player_found=true
	#actor.hb_collision.disabled=true
	actor.hb_collision.set_deferred("disabled", true)
	#bt_player.blackboard.set_var("attack_mode", true)
	actor.animation_player.play(run_anim)
	actor.current_speed=chase_speed

func _exit() -> void:
	actor.current_speed=0
