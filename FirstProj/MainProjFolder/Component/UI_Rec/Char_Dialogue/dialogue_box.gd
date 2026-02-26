extends Control
class_name DialogueBoxController

@onready var top_dialogue: HBoxContainer = $TopDialogue
@onready var portrait_top: TextureRect = $TopDialogue/TextureRect/PortraitContainer/PortraitTop
@onready var char_name_top: RichTextLabel = $TopDialogue/TextureRect/CharNameTop
@onready var dialogue_text_top: dialogue = $TopDialogue/TextureRect2/DialogueContainer/DialogueTextTop

@onready var bottom_dialogue: HBoxContainer = $BottomDialogue
@onready var dialogue_text_bot: dialogue = $BottomDialogue/TextureRect2/DialogueContainer/DialogueTextBot
@onready var portrait_bot: TextureRect = $BottomDialogue/TextureRect/PortraitContainer/PortraitBot
@onready var char_name_bot: RichTextLabel = $BottomDialogue/TextureRect/CharNameBot

signal end_of_dialogue

@onready var dialogue_string : String = "This is a test string, calling from the dialogue box parent node"
@onready var dialogue_speed : float = 1.0
#
#func _ready() -> void:
	#dialogue_text_top.play_dialogue(dialogue_string, dialogue_speed)
	#dialogue_text_bot.play_dialogue("I am a huge furry please rape my face", dialogue_speed)

func play_top(_dialogue_string : String = "This is a test string, calling from the dialogue box parent node",\
 _speed : float = 1.0,\
 _pause_on_finish : bool = true,\
 _character : String = "default",\
 _portrait : String = "default") -> void:
	top_dialogue.call_deferred("set_visible", true)
	dialogue_text_top.play_dialogue(_dialogue_string, _speed)
	portrait_top.texture=load(PortraitsData.portraits[_character][_portrait])
	
func play_bot(_dialogue_string : String = "I am a huge furry please rape my face",\
 _speed : float = 1.0,\
 _pause_on_finish : bool = true,\
 _character : String = "default",\
 _portrait : String = "default") -> void:
	bottom_dialogue.call_deferred("set_visible", true)
	dialogue_text_bot.play_dialogue(_dialogue_string, _speed)
	portrait_bot.texture=load(PortraitsData.portraits[_character][_portrait])
	
func hide_top():
	top_dialogue.call_deferred("set_visible", false)

func hide_bot():
	bottom_dialogue.call_deferred("set_visible", false)

func hide_both():
	top_dialogue.call_deferred("set_visible", false)
	bottom_dialogue.call_deferred("set_visible", false)


func _on_dialogue_text_top_text_finished() -> void:
	end_of_dialogue.emit()


func _on_dialogue_text_bot_text_finished() -> void:
	end_of_dialogue.emit()
