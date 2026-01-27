extends RigidBody2D

var player : PlayerEntity = null

func _ready():
	player = get_tree().get_first_node_in_group("player") 
	sleeping=false

 

func _on_body_entered(body):
	if body.is_in_group("player"):
		player.health.health +=1
		queue_free()
		var hearts = get_tree().get_nodes_in_group("Hearts")
	elif body.is_in_group("WorldStatic") and not sleeping:
		sleeping=true
		#if hearts.size() <=1:
			#Events.level_completed.emit()
			#print("level complete")


#func _on_health_health_depleted():
	#print("Health Depleted!")
	#queue_free()
	#var hearts = get_tree().get_nodes_in_group("Hearts")
	#if hearts.size() <=1:
		#Events.level_completed.emit()
		#print("level complete")
