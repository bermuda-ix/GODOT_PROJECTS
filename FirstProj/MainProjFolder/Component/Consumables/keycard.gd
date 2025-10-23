extends Area2D

var player : PlayerEntity = null

@export var unique_id : String
@export var unique_item : bool = false
@export var flag_name : String
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var global_flag_handler: GlobalFlagHandler = $GlobalFlagHandler

var inv_name : String

func _ready():
	player = get_tree().get_first_node_in_group("player") 
	global_flag_handler.flag_name=flag_name

func _on_body_entered(body):
	if body.is_in_group("player"):
		if unique_item:
			inv_name=name+"."+unique_id
		else:
			inv_name=name
		InventoryDict.add_inv(inv_name)
		Events.global_flag_trigger.emit(flag_name)
		queue_free()
