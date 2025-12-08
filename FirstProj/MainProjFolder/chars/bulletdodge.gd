class_name BulletDodge

extends LimboState

@export var actor : Node2D
@export var state_machine : LimboHSM
@export var animation_player: AnimationPlayer

func _enter() -> void:
	animation_player.speed_scale=1.5
	animation_player.play("bullet_dodge")

func _update(delta: float) -> void:
	await animation_player.animation_finished
	animation_player.speed_scale=1
	state_machine.dispatch(&"finish_bullet_dodge")

func _exit() -> void:
	pass
