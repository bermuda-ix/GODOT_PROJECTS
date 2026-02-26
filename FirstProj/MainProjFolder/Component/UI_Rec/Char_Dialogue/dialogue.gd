extends Control
class_name dialogue

@onready var dialogue_text: RichTextLabel = $DialogueText
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var speed_scale : float = 1.0

signal text_finished

func play_dialogue(_dialogue : String, _speed : float)  -> void:
	dialogue_text.text=_dialogue
	animation_player.speed_scale=_speed
	animation_player.play("Dialogue")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="Dialogue":
		text_finished.emit()
