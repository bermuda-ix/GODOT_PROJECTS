extends Control

@onready var your_score: RichTextLabel = $PanelContainer/RichTextLabel
@onready var name_entry: LineEdit = $PanelContainer3/LineEdit

var score : int = 0

func _ready() -> void:
	score=GlobalSaveData.score
	your_score.text="YOUR SCORE: " + str(score)
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Interact"):
		enter_name(name_entry.text)
	if Input.is_action_just_pressed("DEBUG_KEY"):
		score +=100

func enter_name(_name : String) -> void:
	if _name==null or _name=="":
		print("Enter name ya dingus")
	else:
		#print(_name + " Your score is " + str(score))
		var _new_highscore = HighscoreEntryClass.new()
		_new_highscore.name=_name
		_new_highscore.score=score
		GlobalSaveData.store_score(_new_highscore)
