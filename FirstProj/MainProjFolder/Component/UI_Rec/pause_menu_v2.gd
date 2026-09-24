extends Control

@onready var main_pause: Control = $TextureRect/MainPause
@onready var controls_menu: Control = $TextureRect/ControlsMenu
@onready var return_button: TextureButton = $TextureRect/MainPause/VBoxContainer/ReturnButton
@onready var keyboard_mouse: Control = $TextureRect/ControlsMenu/KeyboardMouse
@onready var gamepad: Control = $TextureRect/ControlsMenu/Gamepad
@onready var back_button: TextureButton = $TextureRect/ControlsMenu/KeyboardMouse/VBoxContainer/BackButton
@onready var back_button_game_pad: TextureButton = $TextureRect/ControlsMenu/Gamepad/BackButtonGamePad


func _ready() -> void:
	return_button.grab_focus()
	

func _process(delta: float) -> void:
	pass


func _on_controls_button_pressed() -> void:
	main_pause.visible=false
	controls_menu.visible=true
	back_button.grab_focus()
	back_button_game_pad.grab_focus()


func _on_back_button_pressed() -> void:
	main_pause.visible=true
	controls_menu.visible=false
	return_button.grab_focus()


func _on_return_button_pressed() -> void:
	Events.unpause.emit()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_back_button_game_pad_pressed() -> void:
	main_pause.visible=true
	controls_menu.visible=false

func change_scheme(_gamepad: bool) -> void:
	if _gamepad:
		gamepad.visible=true
		keyboard_mouse.visible=false
		back_button_game_pad.grab_focus()
	else:
		gamepad.visible=false
		keyboard_mouse.visible=true
		back_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouse:
		change_scheme(false)
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		change_scheme(true)
