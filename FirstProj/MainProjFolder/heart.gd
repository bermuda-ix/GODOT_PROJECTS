extends Area2D


func _on_body_entered(_body):
	queue_free()
	var hearts = get_tree().get_nodes_in_group("Hearts")
	if hearts.size() <=1:
		Events.level_completed.emit()
		print("level complete")


#func _on_health_health_depleted():
	#print("Health Depleted!")
	#queue_free()
	#var hearts = get_tree().get_nodes_in_group("Hearts")
	#if hearts.size() <=1:
		#Events.level_completed.emit()
		#print("level complete")

