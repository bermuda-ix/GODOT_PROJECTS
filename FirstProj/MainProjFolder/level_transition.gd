extends CanvasLayer

@onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func fade_from_black():
	animation_player.play("fade_from_black")
	await animation_player.animation_finished
	
func fade_to_black():
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
