extends Control
class_name dialogue

@onready var dialogue_text: RichTextLabel = $DialogueText
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var speed_scale : float = 1.0
@onready var dialogue_timer: Timer = $DialogueTimer




signal text_finished

func _process(delta: float) -> void:
	if dialogue_text.visible_ratio<1.0 and not dialogue_timer.is_stopped():
		if dialogue_text.visible_ratio>=1.0:
			dialogue_timer.stop()

func play_dialogue(_dialogue : String, _speed : String)  -> void:
	dialogue_text.text=_dialogue
	dialogue_text.visible_ratio=0
	#animation_player.speed_scale=_speed
	#animation_player.play("Dialogue")
	#dialogue_timer.start(_speed)
	match _speed:
		"Slow" : dialogue_timer.start(0.1)
		"Default" : dialogue_timer.start(0.05)
		"Fast" : dialogue_timer.start(0.01)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="Dialogue":
		text_finished.emit()

func skip_to_end() -> void:
	animation_player.stop()
	dialogue_timer.stop()
	dialogue_text.visible_ratio=1.0


func _on_dialogue_timer_timeout() -> void:
	dialogue_text.visible_characters+=1
