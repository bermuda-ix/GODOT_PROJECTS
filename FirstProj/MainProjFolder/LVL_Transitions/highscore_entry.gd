extends Control

@onready var your_score: RichTextLabel = $PanelContainer/RichTextLabel
@onready var name_entry: LineEdit = $PanelContainer3/LineEdit
@onready var save_load_scores: Node = $SaveLoadScores


var score : int = 25

func _ready() -> void:
	#score=GlobalSaveData.score
	your_score.text="YOUR SCORE: " + str(score)
	
	
	#Global.game_controller.call_preload_scene(LevelsList.HIGHSCORE_LIST)
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Interact"):
		enter_score()
	#if Input.is_action_just_pressed("DEBUG_KEY"):
		#score +=100
	#if Input.is_action_just_pressed("MAnualLoad"):
		#GlobalSaveData.load_highscores()

func enter_name(_name : String) -> void:
	if _name==null or _name=="":
		print_debug("Enter name ya dingus")
	else:
		print_debug(_name + " Your score is " + str(score))
		save_load_scores.send_score("EASY", name_entry.text, score)
		var _new_highscore : Array
		_new_highscore = [_name, GlobalSaveData.score]
		#GlobalSaveData.store_score(_new_highscore)


func _on_texture_button_pressed() -> void:
	enter_score()
	

func enter_score() -> void:
	enter_name(name_entry.text)
	
	

func enter_score_test() -> void:
	enter_name(name_entry.text)
	#var HIGHSCORE_LIST = load("res://LVL_Transitions/highscore_list.tscn")
	#get_tree().change_scene_to_packed(HIGHSCORE_LIST)
	#


func _on_save_load_scores_score_sent() -> void:
	###Debug change
	get_tree().change_scene_to_file("res://LVL_Transitions/highscore_list.tscn")
	pass
	
	#Global.game_controller.change_gui_scene(LevelsList.HIGHSCORE_LIST)
