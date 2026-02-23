extends Control

@onready var portrait: TextureRect = $HBoxContainer/TextureRect/PortraitContainer/Portrait
@onready var char_name: RichTextLabel = $HBoxContainer/TextureRect/CharName
@onready var dialogue_text: dialogue = $HBoxContainer/TextureRect2/DialogueContainer/DialogueText


@onready var dialogue_string : String = "This is a test string, calling from the dialogue box parent node"
@onready var dialogue_speed : float = 1.0

func _ready() -> void:
	dialogue_text.play_dialogue(dialogue_string, dialogue_speed)
