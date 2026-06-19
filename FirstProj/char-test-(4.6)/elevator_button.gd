class_name ElevatorButton extends TextureButton

var button_text : String = "TEST"
var floor_locked : bool = false
@onready var key_type : String = "ElevatorKeyCard"
@onready var rich_text_label: RichTextLabel = $PanelContainer/RichTextLabel
signal floor

func _ready() -> void:
	rich_text_label.text=str("FLOOR " + button_text)
	


func _on_pressed() -> void:
	if floor_locked:
		if InventoryDict.player_inventory.has(key_type):
			toggle_floor_lock(true)
			print_debug("Floor unlocked")
		else:
			print_debug("Floor locked")
			return
	var regex = RegEx.new()
	regex.compile("\\d+")
	var _floor_number_tmp = regex.search_all(button_text)
	var _floor_number : int
	for number in _floor_number_tmp:
		_floor_number=int(number.get_string())
	floor.emit(_floor_number)

func toggle_floor_lock(value : bool) -> void:
	floor_locked = value
	#print_debug(floor_locked)
