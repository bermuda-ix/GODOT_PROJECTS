class_name TargetLockVisual
extends Node2D

@onready var animation_player = $Sprite2D/AnimationPlayer
@onready var sprite_2d = $Sprite2D
@onready var label = $Sprite2D/Label

func _ready():
	animation_player.play("default")
	sprite_2d.visible=true
	sprite_2d.global_position=global_position
	Events.unlock_from.connect(unlock_from)
	
func _process(delta):
	label.text=str(sprite_2d.global_position)

func unlock_from():
	queue_free()
