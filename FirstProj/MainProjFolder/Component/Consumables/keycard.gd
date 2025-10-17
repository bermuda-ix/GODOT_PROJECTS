extends Area2D

var player : PlayerEntity = null

@export var unique_id : String 
var inv_name : String

func _ready():
	player = get_tree().get_first_node_in_group("player") 

func _on_body_entered(body):
	if body.is_in_group("player"):
		if unique_id != null:
			inv_name=name+"."+unique_id
		else:
			inv_name=name
		InventoryDict.add_inv(inv_name)
		queue_free()
