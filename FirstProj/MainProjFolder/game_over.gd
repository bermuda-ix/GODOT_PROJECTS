extends ColorRect


func _on_button_pressed():
	get_tree().paused=false
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://main_menu.tscn")
	LevelTransition.fade_from_black()
