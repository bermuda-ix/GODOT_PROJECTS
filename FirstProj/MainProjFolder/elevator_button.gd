class_name ElevatorButton extends TextureButton

var button_text : String = "TEST"
var floor_locked : bool = false
@onready var key_type : String = "ElevatorKeyCard"
@onready var rich_text_label: RichTextLabel = $PanelContainer/RichTextLabel
signal floor

func _ready() -> void:
	
	if floor_locked:
		modulate = Color(0.234, 0.234, 0.234, 0.8)
		rich_text_label.text=str("LOCKED")
	else:
		modulate = Color(1.0, 1.0, 1.0, 1.0)
		rich_text_label.text=str("FLOOR " + button_text)
	
#func _process(delta: float) -> void:
	#rich_text_label = $PanelContainer/RichTextLabel

func _on_pressed() -> void:
	if floor_locked:
		if InventoryDict.player_inventory.has(key_type):
			toggle_floor_lock(true)
			#print_debug("Floor unlocked")
		else:
			#print_debug("Floor locked")
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
	if value:
		modulate = Color(0.234, 0.234, 0.234, 0.8)
		rich_text_label = $PanelContainer/RichTextLabel
		rich_text_label.text=str("LOCKED")
	else:
		modulate = Color(1.0, 1.0, 1.0, 1.0)
		rich_text_label = $PanelContainer/RichTextLabel
		rich_text_label.text=str("FLOOR " + button_text)
		
	#print_debug(floor_locked)
