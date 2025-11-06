extends Control

@onready var main_pause: Control = $TextureRect/MainPause
@onready var controls_menu: Control = $TextureRect/ControlsMenu


func _process(delta: float) -> void:
	pass


func _on_controls_button_pressed() -> void:
	main_pause.visible=false
	controls_menu.visible=true


func _on_back_button_pressed() -> void:
	main_pause.visible=true
	controls_menu.visible=false


func _on_return_button_pressed() -> void:
	Events.unpause.emit()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
