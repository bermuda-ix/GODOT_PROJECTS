extends VBoxContainer

@onready var score : int = 0
@onready var score_counter_text: RichTextLabel = $ScoreCounter/ScoreCounterText

func _ready() -> void:
	Events.inc_score.connect(score_increase)

func score_increase(value : int) -> void:
	score += value
	score_counter_text.text=str(score)
