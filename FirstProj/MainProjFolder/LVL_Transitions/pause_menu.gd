extends ColorRect



func _on_quit_pressed():
	get_tree().quit()


func _on_continue_pressed():
	Events.unpause.emit()
