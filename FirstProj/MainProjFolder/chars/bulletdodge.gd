class_name BulletDodge

extends LimboState

@export var actor : Node2D
@export var state_machine : LimboHSM
@export var animation_player: AnimationPlayer

func _enter() -> void:
	animation_player.play("bullet_dodge")

func _update(delta: float) -> void:
	await animation_player.animation_finished
	state_machine.dispatch(&"finish_dodge")

func _exit() -> void:
	pass
