extends AnimatedSprite2D

@onready var dodge_success: AnimatedSprite2D = $"."
@onready var animation_player: AnimationPlayer = $AnimationPlayer



func play_vfx():
	animation_player.play("dodge_success")
	animation_player.speed_scale=1/Engine.time_scale


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
