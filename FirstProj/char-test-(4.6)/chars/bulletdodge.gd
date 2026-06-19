class_name BulletDodge

extends LimboState

@export var actor : Node2D
@export var state_machine : LimboHSM
@export var animation_player: AnimationPlayer

func _enter() -> void:
	animation_player.speed_scale=1.5
	animation_player.play("bullet_dodge")

func _update(delta: float) -> void:
	pass
	#await animation_player.animation_finished
	#animation_player.speed_scale=1
	#
	#
	#if actor.states_stack.is_empty():
		#state_machine.dispatch(&"finish_bullet_dodge")
	#elif actor.states_stack[0]==actor.attack:
		#state_machine.dispatch(&"resume_attack")
		#actor.states_stack.pop_back()
	#else:
		#state_machine.dispatch(&"finish_bullet_dodge")

func _exit() -> void:
	animation_player.speed_scale=1
	pass
