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

var _name_list : Array
var _score_list : Array
var _list_size : int
var _loaded_scores

func _ready() -> void:
	_score_list = get_tree().get_nodes_in_group("score")
	_name_list = get_tree().get_nodes_in_group("name")
	_list_size = _name_list.size()
	load_scores()
	
	
func load_scores() -> void:
	var _file = FileAccess.open( GlobalSaveData.SAVE_PATH + "highscores//highscores_list.sav", FileAccess.READ)
	var _load_json = JSON.new()
	var _parse_result = _load_json.parse(_file.get_line())
	if not  _parse_result == OK:
		print("JSON Parse Error: ", _load_json.get_error_message(), " in ", _file, " as line ", _load_json.get_error_line())
		return
	_loaded_scores = _load_json.get_data() as Array[Array]
	if _list_size>_loaded_scores.size():
		_list_size=_loaded_scores.size()
	display_scores(_list_size, _loaded_scores)
	
func display_scores(_size : int, _list : Array) -> void:
	for i in range(_size-1, -1, -1):
		_name_list[i].text=str(_list[i][0])
		_score_list[i].text=str(_list[i][1])
