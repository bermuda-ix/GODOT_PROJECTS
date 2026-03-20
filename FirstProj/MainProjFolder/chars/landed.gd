extends LimboState

@export var animation_player : AnimationPlayer
@export var actor : Node2D
@onready var landed_type : String = "landed"
signal landed

func _enter() -> void:
	animation_player.play(landed_type)
	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="landed" or anim_name=="landed_recover":
		landed.emit()
