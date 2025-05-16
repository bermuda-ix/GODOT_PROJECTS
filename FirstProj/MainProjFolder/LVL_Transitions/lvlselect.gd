extends CenterContainer



func _on_guanlet_pressed():
	pass
	#await LevelTransition.fade_to_black()
	#get_tree().change_scene_to_file("res://levels/guantlet.tscn")
	#LevelTransition.fade_from_black()



func _on_boss_pressed():
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file(LevelList.PROLOGUE_LVL)
	LevelTransition.fade_from_black()


func _on_tutorials_pressed() -> void:
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file(LevelList.CONTROL_TEST)
	LevelTransition.fade_from_black()
