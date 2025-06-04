extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity
@export var hit_stop : HitStop
@onready var parry_success_state: LimboHSM = $".."


func _enter() -> void:
	print("how do you pronouce riposte")
	anim_player.play("Riposte")
	hit_stop.end_hit_stop()
	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="Riposte":
		pc.state_machine.dispatch(&"return_to_idle")
