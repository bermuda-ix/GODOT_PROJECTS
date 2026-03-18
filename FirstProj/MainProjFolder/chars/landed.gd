extends LimboState

@export var animation_player : AnimationPlayer
@export var actor : Node2D
signal landed

func _enter() -> void:
	animation_player.play("landed")
	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="landed":
		landed.emit()
