extends LimboState

@onready var recover_anim = "hit_recover"
@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity
@export var state_machine : LimboHSM

func _enter() -> void:
	anim_player.play(recover_anim)
	
func _update(delta: float) -> void:
	if pc.hit_timer.is_stopped():
		state_machine.dispatch(&"return_to_idle")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name==recover_anim:
		state_machine.dispatch(&"return_to_idle")
