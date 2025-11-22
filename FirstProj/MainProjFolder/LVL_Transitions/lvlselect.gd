extends CenterContainer



func _on_guanlet_pressed():
	pass
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://levels/guantlet.tscn")
	LevelTransition.fade_from_black()



func _on_boss_pressed():
	await LevelTransition.fade_to_black()
	
	Global.game_controller.load_levels(LevelsList.prologue_unique_levels)
	Global.game_controller.load_levels(LevelsList.prologue_level_maps)
	Global.game_controller._init_objectives(ObjectivesByLevel.prologue_init_objectives)
	Global.game_controller.toggle_player(true)
	Global.game_controller.change_2d_scene("PrologueLvl", true, false, -1, "fade_to_black_quick", "fade_from_black_quick")
	Global.game_controller.toggle_game_ui(true)
	Global.game_controller.toggle_world2d_process(true)
	Global.game_controller.remove_gui_scene()
	
	LevelTransition.fade_from_black()


func _on_tutorials_pressed() -> void:
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file(LevelList.CONTROL_TEST)
	LevelTransition.fade_from_black()
