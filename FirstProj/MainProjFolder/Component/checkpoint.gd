extends Area2D

@onready var check_flag = $CollisionShape2D

@export var player : PlayerEntity

func _ready():
	check_flag.disabled=false
	player=get_tree().get_first_node_in_group("player")

func get_sate() -> bool:
	return check_flag.disabled
	
func _on_body_entered(body):
	if body.is_in_group("player") and check_flag.disabled==false:
		print_debug("checkpoint reached")
		#check_flag.disabled=true
		check_flag.call_deferred("set_disabled", true)
		body.set_start_pos(position)
		GlobalSaveData.current_save["player"]["pos_x"]=global_position.x
		GlobalSaveData.current_save["player"]["pos_y"]=global_position.y
		var _flags = get_tree().get_nodes_in_group("flags")
		for _flag in _flags:
			if "flag_active" in _flag:
				GlobalSaveData.current_save["flags"][_flag.name]=_flag.get_active()
		var _checkpoint=name.substr(name.length(), 1)
		if _checkpoint.is_valid_int() and _checkpoint!="1":
			GlobalSaveData.level_state["checkpoint_reached"]=_checkpoint
		else:
			GlobalSaveData.level_state["checkpoint_reached"]="1"
		Events.checkpoint_reached.emit()


func _on_persistant_state_handler_update_state(value: String) -> void:
	if value=="true":
		check_flag.disabled=true
	else:
		check_flag.disabled=false


func _activate_checkpoint() -> void:
	check_flag.call_deferred("set_disabled", false)


func _on_local_flag_event_flag_triggered() -> void:
	pass # Replace with function body.
