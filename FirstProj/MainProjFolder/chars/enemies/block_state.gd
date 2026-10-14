class_name BlockState extends LimboState

@export var animation_player : AnimationPlayer = null
@export var shield : Area2D = null
@export var shield_collision : CollisionShape2D = null

func _enter() -> void:
	animation_player.play("block")
	shield_collision.set_deferred("disabled", false)
