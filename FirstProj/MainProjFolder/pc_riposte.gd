extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity
@export var hit_stop : HitStop
@onready var parry_success_state: LimboHSM = $".."


func _enter() -> void:
	print("how do you pronouce riposte")
	anim_player.play("Attack_Counter")
	hit_stop.end_hit_stop()
	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="Attack_Counter":
		pc.state_machine.dispatch(&"return_from_parry")
