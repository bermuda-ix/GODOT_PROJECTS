extends Area2D

@onready var check_flag = $CollisionShape2D

@export var player : PlayerEntity

func _ready():
	check_flag.disabled=false

func _on_body_entered(body):
	if body.is_in_group("player") and check_flag.disabled==false:
		print("checkpoint reached")
		check_flag.disabled=true
		$"../PC".set_start_pos(position)
		GlobalSaveData.current_save["player"]["pos_x"]=global_position.x
		GlobalSaveData.current_save["player"]["pos_y"]=global_position.y
		var _checkpoint=name.substr(name.length(), 1)
		if _checkpoint.is_valid_int() and _checkpoint!="1":
			GlobalSaveData.level_state["checkpoint_reached"]=_checkpoint
		else:
			GlobalSaveData.level_state["checkpoint_reached"]="1"
		Events.checkpoint_reached.emit()
