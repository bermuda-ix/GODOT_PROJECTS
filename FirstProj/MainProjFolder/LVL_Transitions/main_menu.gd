extends CenterContainer

@onready var start_game_button = %StartGameButton
@onready var quit_button = %QuitButton


func _ready():
	start_game_button.grab_focus()

func _on_start_game_button_pressed():
	await LevelTransition.fade_to_black()
	

	Global.game_controller.change_gui_scene(LevelsList.LEVEL_SELECT)
	LevelTransition.fade_from_black()

func _on_quit_button_pressed():
	get_tree().quit()
