class_name PreparingCounterState extends LimboState

@export var animation_player : AnimationPlayer
@export var prepare_counter_anim : String = "preparing_counter"

signal counter_attack

func _ready():
	animation_player.animation_finished.connect(counter_prepared)
	
func _enter() -> void:
	animation_player.play(prepare_counter_anim)
	
func _exit() -> void:
	pass
	
func counter_prepared(anim_name : String) -> void:
	if anim_name==prepare_counter_anim:
		counter_attack.emit()
