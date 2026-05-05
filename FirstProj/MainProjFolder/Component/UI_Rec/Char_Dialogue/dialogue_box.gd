extends Control
class_name DialogueBoxController

@onready var top_dialogue: HBoxContainer = $TopDialogue
@onready var portrait_top: TextureRect = $TopDialogue/TextureRect/PortraitContainer/PortraitTop
@onready var char_name_top: RichTextLabel = $TopDialogue/TextureRect/CharNameTop
@onready var dialogue_text_top: dialogue = $TopDialogue/TextureRect2/DialogueContainer/DialogueTextTop
@onready var wait_for_prompt_top: Control = $TopDialogue/TextureRect2/WaitForPromptTop
@onready var click_prompt_player_top: AnimationPlayer = $TopDialogue/TextureRect2/WaitForPromptTop/ClickPromptTop/ClickPromptPlayerTop
@onready var playing_top : bool = false

@onready var bottom_dialogue: HBoxContainer = $BottomDialogue
@onready var dialogue_text_bot: dialogue = $BottomDialogue/TextureRect2/DialogueContainer/DialogueTextBot
@onready var portrait_bot: TextureRect = $BottomDialogue/TextureRect/PortraitContainer/PortraitBot
@onready var char_name_bot: RichTextLabel = $BottomDialogue/TextureRect/CharNameBot
@onready var wait_for_prompt_bot: Control = $BottomDialogue/TextureRect/WaitForPromptBot
@onready var click_prompt_player_bot: AnimationPlayer = $BottomDialogue/TextureRect/WaitForPromptBot/ClickPromptBot/ClickPromptPlayerBot
@onready var playing_bot : bool = false

@onready var autoplay_next

@export_category("dialogue speed")
#@onready var slow : float=0.1
#@onready var default: float=0.05
#@onready var fast: float=0.01
@export_enum("Slow", "Default", "Fast") var talk_speed: String

signal end_of_dialogue



@onready var dialogue_string : String = "This is a test string, calling from the dialogue box parent node"
@onready var dialogue_speed : float = 1.0
#
#func _ready() -> void:
	#dialogue_text_top.play_dialogue(dialogue_string, dialogue_speed)
	#dialogue_text_bot.play_dialogue("I am a huge furry please rape my face", dialogue_speed)


func play_top(_dialogue_string : String = "This is a test string, calling from the dialogue box parent node",\
 _speed : String = "Default",\
 _autoplay : bool = false,\
 _character : String = "default",\
 _portrait : String = "default",\
 _name : String = "???") -> void:
	hide_wait_for_input()
	portrait_top.texture=load(PortraitsData.portraits[_character][_portrait])
	char_name_top.text=_name
	top_dialogue.call_deferred("set_visible", true)
	dialogue_text_top.play_dialogue(_dialogue_string, _speed)
	playing_top=true
	autoplay_next=_autoplay
	
	
func play_bot(_dialogue_string : String = "I am a huge furry please rape my face",\
 _speed : String = "Default",\
 _autoplay : bool = false,\
 _character : String = "default",\
 _portrait : String = "default",\
 _name : String = "???") -> void:
	hide_wait_for_input()
	portrait_bot.texture=load(PortraitsData.portraits[_character][_portrait])
	char_name_bot.text=_name
	bottom_dialogue.call_deferred("set_visible", true)
	dialogue_text_bot.play_dialogue(_dialogue_string, _speed)
	playing_bot=true
	autoplay_next=_autoplay
	
	
func hide_top():
	top_dialogue.call_deferred("set_visible", false)

func hide_bot():
	bottom_dialogue.call_deferred("set_visible", false)

func hide_both():
	top_dialogue.call_deferred("set_visible", false)
	bottom_dialogue.call_deferred("set_visible", false)


func _on_dialogue_text_top_text_finished() -> void:
	end_of_dialogue.emit()
	playing_top=false
	if not autoplay_next:
		wait_for_input()


func _on_dialogue_text_bot_text_finished() -> void:
	end_of_dialogue.emit()
	playing_bot=false
	if not autoplay_next:
		wait_for_input()
	
func wait_for_input():
	wait_for_prompt_bot.set_deferred("visible", true)
	wait_for_prompt_top.set_deferred("visible", true)
	click_prompt_player_bot.play("wait_for_input")
	click_prompt_player_top.play("wait_for_input")

func hide_wait_for_input():
	wait_for_prompt_bot.set_deferred("visible", false)
	wait_for_prompt_top.set_deferred("visible", false)
	click_prompt_player_bot.stop()
	click_prompt_player_top.stop()

func skip_to_end() -> void:
	dialogue_text_bot.skip_to_end()
	dialogue_text_top.skip_to_end()
	playing_bot=false
	playing_top=false
	wait_for_input()

func auto_play_next() -> void:
	pass
