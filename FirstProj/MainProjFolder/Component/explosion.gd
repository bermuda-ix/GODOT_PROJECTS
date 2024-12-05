extends AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var audio_stream_player_2d = $AudioStreamPlayer2D

func _process(_delta):
	explode()

func explode():
	animation_player.play("explode")
	animation_player.speed_scale=1.75
	audio_stream_player_2d.play()
	await animation_player.animation_finished
	queue_free()
