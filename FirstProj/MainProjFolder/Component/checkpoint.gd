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
		Events.set_player_data.emit()
