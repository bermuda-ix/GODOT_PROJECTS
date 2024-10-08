extends CenterContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://.godot/exported/133200997/export-8b03550a1e82db90fe95208a9e9dbb82-main_menu.scn")
	

func _on_quit_pressed():
	get_tree().quit()
