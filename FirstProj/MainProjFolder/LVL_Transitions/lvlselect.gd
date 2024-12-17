extends CenterContainer



func _on_guanlet_pressed():
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://levels/guantlet.tscn")
	LevelTransition.fade_from_black()



func _on_boss_pressed():
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://levels/boss_test.tscn")
	LevelTransition.fade_from_black()


func _on_tutorials_pressed():
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://LVL_Transitions/control_guide.tscn")
	LevelTransition.fade_from_black()
