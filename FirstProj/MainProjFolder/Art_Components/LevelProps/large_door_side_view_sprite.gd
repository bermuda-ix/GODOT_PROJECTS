extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var open_state := false



func open():
	animation_player.play("Open")
	open_state = true
	
func close():
	animation_player.play_backwards("Open")
	open_state = false
