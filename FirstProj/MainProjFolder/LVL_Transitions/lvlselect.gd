extends CenterContainer

@onready var boss: Button = $VBoxContainer/boss


func _on_guanlet_pressed():
	await LevelTransition.fade_to_black()
	Events.reset_player_data.emit()
	Global.game_controller.load_levels(LevelsList.guantlet_lvls)
	if not LevelsList.level_maps.is_empty():
		Global.game_controller.load_levels(LevelsList.level_maps)
	Global.game_controller._init_objectives(ObjectivesByLevel.guanlet_init_objectives)
	#Global.game_controller.toggle_player(true)
	Global.game_controller.change_2d_scene("GuantletLvl", true, false, -1, "fade_to_black_quick", "fade_from_black_quick")
	Global.game_controller.toggle_game_ui(true)
	#Global.game_controller.toggle_world2d_process(true)
	Global.game_controller.call_deferred("toggle_world2d_process", true)
	Global.game_controller.remove_gui_scene()
	Global.game_controller.add_gui_to_existing("res://Component/UI_Rec/score_ui.tscn")
	
	LevelTransition.fade_from_black()



func _on_boss_pressed():
	await LevelTransition.fade_to_black()
	
	boss.set_deferred("disabled", true)
	#Global.game_controller.load_levels(LevelsList.prologue_unique_levels)
	#Global.game_controller.load_levels(LevelsList.level_maps)
	Global.game_controller._init_objectives(ObjectivesByLevel.prologue_init_objectives)
		
	#Global.game_controller.toggle_player(true)
	Global.game_controller.toggle_game_ui(true)
	Global.game_controller.toggle_world2d_process(true)
	Global.game_controller.remove_gui_scene()
	
	#Global.game_controller.change_2d_scene("PrologueLvl", true, false, -1, "fade_to_black_quick", "fade_from_black_quick")
	Global.game_controller.load_cutscene("IntroCutscene")
	
	
	
	#LevelTransition.fade_from_black()


func _on_tutorials_pressed() -> void:
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file(LevelList.CONTROL_TEST)
	LevelTransition.fade_from_black()
