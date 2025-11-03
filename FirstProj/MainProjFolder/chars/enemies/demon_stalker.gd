extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var local_flag__appear: LocalFlag = $"LocalFlags/LocalFlag->Appear"
@onready var local_flag__disappear: LocalFlag = $"LocalFlags/LocalFlag->Disappear"


func _ready() -> void:
	animation_player.play("idle")
	

func _on_local_flag_appear_flag_triggered() -> void:
	visible=true
	local_flag__appear.flag_active=false
	local_flag__disappear.flag_active=true
	
func _on_local_flag_disappear_flag_triggered() -> void:
	visible=false
	local_flag__disappear.flag_active=false
	queue_free()



func _on_global_flag_handler_flag_activate() -> void:
	local_flag__appear.flag_active=true
