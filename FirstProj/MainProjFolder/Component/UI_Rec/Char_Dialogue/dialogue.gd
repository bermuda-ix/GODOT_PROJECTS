extends Control
class_name dialogue

@onready var dialogue_text: RichTextLabel = $DialogueText
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var speed_scale : float = 1.0


func play_dialogue(_dialogue : String, _speed : float)  -> void:
	dialogue_text.text=_dialogue
	animation_player.speed_scale=_speed
	animation_player.play("Test")
