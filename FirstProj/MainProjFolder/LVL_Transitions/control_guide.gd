extends CanvasLayer

@onready var begin = $VBoxContainer2/Begin

# Called when the node enters the scene tree for the first time.
func _ready():
	begin.grab_focus()



func _on_begin_pressed():
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://levels/control_test.tscn")
	LevelTransition.fade_from_black()
