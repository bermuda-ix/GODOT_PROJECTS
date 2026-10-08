extends GPUParticles2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	emitting=true
	audio_stream_player_2d.stream=load(SoundFx.QUBODUP_BANG_SHORT)
	audio_stream_player_2d.play()

func _process(delta: float) -> void:
	pass
	#if not emitting:
		#queue_free()


func _on_audio_stream_player_2d_finished() -> void:
	queue_free()
