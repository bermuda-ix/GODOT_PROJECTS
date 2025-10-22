extends ColorRect

func _process(delta: float) -> void:
	pass
	

func _on_quit_pressed():
	get_tree().quit()


func _on_continue_pressed():
	Events.unpause.emit()
