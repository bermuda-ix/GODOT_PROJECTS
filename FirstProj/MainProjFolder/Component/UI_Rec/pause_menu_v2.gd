extends Control

@onready var main_pause: Control = $TextureRect/MainPause
@onready var controls_menu: Control = $TextureRect/ControlsMenu
@onready var return_button: TextureButton = $TextureRect/MainPause/VBoxContainer/ReturnButton
@onready var keyboard_mouse: Control = $TextureRect/ControlsMenu/KeyboardMouse
@onready var gamepad: Control = $TextureRect/ControlsMenu/Gamepad
@onready var back_button: TextureButton = $TextureRect/ControlsMenu/KeyboardMouse/VBoxContainer/BackButton
@onready var back_button_game_pad: TextureButton = $TextureRect/ControlsMenu/Gamepad/BackButtonGamePad

@onready var gamepad_button_focus := false

func _ready() -> void:
	return_button.grab_focus()
	main_pause.visibility_changed.connect(return_button_focus)
	visibility_changed.connect(return_button_focus)
	keyboard_mouse.visibility_changed.connect(back_button_focus)
	gamepad.visibility_changed.connect(back_button_gamepad_focus)

func _process(delta: float) -> void:
	pass

func return_button_focus() -> void:
	if main_pause.visible and visible:
		return_button.call_deferred("grab_focus")
	
func back_button_focus()-> void:
	if keyboard_mouse.visible and controls_menu.visible:
		back_button.call_deferred("grab_focus")
	
func back_button_gamepad_focus()-> void:
	if gamepad.visible and controls_menu.visible:
		back_button_game_pad.call_deferred("grab_focus")


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
		#back_button_game_pad.grab_focus()
	else:
		gamepad.visible=false
		keyboard_mouse.visible=true
		#back_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouse:
		change_scheme(false)
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		change_scheme(true)
		
