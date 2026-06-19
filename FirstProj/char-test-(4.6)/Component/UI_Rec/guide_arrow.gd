extends Control

@export var flip_arrow := false
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play("main")
	sprite_2d.flip_h=flip_arrow
