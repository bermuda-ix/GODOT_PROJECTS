class_name ElevatorButton extends TextureButton

var button_text : String = "TEST"
@onready var rich_text_label: RichTextLabel = $PanelContainer/RichTextLabel
signal floor

func _ready() -> void:
	rich_text_label.text=str("FLOOR " + button_text)
	


func _on_pressed() -> void:
	var regex = RegEx.new()
	regex.compile("\\d+")
	var _floor_number_tmp = regex.search_all(button_text)
	var _floor_number : int
	for number in _floor_number_tmp:
		_floor_number=int(number.get_string())
	floor.emit(_floor_number)
