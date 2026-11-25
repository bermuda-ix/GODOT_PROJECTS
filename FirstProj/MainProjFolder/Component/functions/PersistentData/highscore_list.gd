extends Control

@onready var name_list: VBoxContainer = $NameList
@onready var name_panel: PanelContainer = $NameList/NamePanel
@onready var name_text: RichTextLabel = $NameList/NamePanel/NameText

@onready var score_list: VBoxContainer = $ScoreList
@onready var score_panel: PanelContainer = $ScoreList/ScorePanel
@onready var score_text: RichTextLabel = $ScoreList/ScorePanel/ScoreText

@onready var name_panel_1: PanelContainer = $NameList/NamePanel1
@onready var name_1: RichTextLabel = $NameList/NamePanel1/Name1
@onready var name_panel_2: PanelContainer = $NameList/NamePanel2
@onready var name_2: RichTextLabel = $NameList/NamePanel2/Name2
@onready var name_panel_3: PanelContainer = $NameList/NamePanel3
@onready var name_3: RichTextLabel = $NameList/NamePanel3/Name3
@onready var name_panel_4: PanelContainer = $NameList/NamePanel4
@onready var name_4: RichTextLabel = $NameList/NamePanel4/Name4
@onready var name_panel_5: PanelContainer = $NameList/NamePanel5
@onready var name_5: RichTextLabel = $NameList/NamePanel5/Name5

@onready var score_panel_1: PanelContainer = $ScoreList/ScorePanel1
@onready var score_1: RichTextLabel = $ScoreList/ScorePanel1/Score1
@onready var score_panel_2: PanelContainer = $ScoreList/ScorePanel2
@onready var score_2: RichTextLabel = $ScoreList/ScorePanel2/Score2
@onready var score_panel_3: PanelContainer = $ScoreList/ScorePanel3
@onready var score_3: RichTextLabel = $ScoreList/ScorePanel3/Score3
@onready var score_panel_4: PanelContainer = $ScoreList/ScorePanel4
@onready var score_4: RichTextLabel = $ScoreList/ScorePanel4/Score4
@onready var score_panel_5: PanelContainer = $ScoreList/ScorePanel5
@onready var score_5: RichTextLabel = $ScoreList/ScorePanel5/Score5

@onready var save_load_scores: SaveLoadScores = $SaveLoadScores

var _name_list : Array
var _score_list : Array
var _list_size : int
var _loaded_scores

func _ready() -> void:
	_score_list = get_tree().get_nodes_in_group("score")
	_name_list = get_tree().get_nodes_in_group("name")
	_list_size = _name_list.size()
	#load_scores()
	save_load_scores.recieve_scores()
	
	
func load_scores() -> void:
	var _file = FileAccess.open( GlobalSaveData.SAVE_PATH + "highscores//highscores_list.sav", FileAccess.READ)
	var _load_json = JSON.new()
	var _parse_result = _load_json.parse(_file.get_line())
	if not  _parse_result == OK:
		print_debug("JSON Parse Error: ", _load_json.get_error_message(), " in ", _file, " as line ", _load_json.get_error_line())
		return
	_loaded_scores = _load_json.get_data() as Array[Array]
	if _list_size>_loaded_scores.size():
		_list_size=_loaded_scores.size()
	else:
		_list_size=5
	display_scores(_list_size, _loaded_scores)
	
func display_scores(_size : int, _list : Array) -> void:
	assert(_size<=5)
	for i in range(_size-1, -1, -1):
		var _name=str(_list[i]["Name"])
		var _score=str(_list[i]["Score"])
		_name_list[i].text=_name
		_score_list[i].text=_score


func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_return_pressed() -> void:
	GlobalSaveData.score=0
	Global.game_controller.change_gui_scene(LevelsList.MAIN_MENU)
	Global.game_controller.reload_game()


func _on_save_load_scores_scores_recieved(response_text: String) -> void:
	var json = JSON.new()
	json.parse(response_text)
	var _recieved_scores : Array = json.data
	#var _scores_sorted : Array = []
	if _list_size>_recieved_scores.size():
		_list_size=_recieved_scores.size()
	_recieved_scores.sort_custom(sort_descending)
	display_scores(_list_size, _recieved_scores)

func sort_top_five(_scores) -> void:
	pass
	
static func sort_descending(a: Dictionary, b: Dictionary)-> bool:
	return int(a["Score"]>b["Score"])
