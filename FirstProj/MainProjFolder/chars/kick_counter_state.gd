extends LimboState

@export var anim_player : AnimationPlayer
@export var actor : Node2D

func _enter() -> void:
	print("kick counter")
	anim_player.play("kick_counter")
	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="kick_counter":
		actor.state_machine.dispatch(&"counter_end")
		actor.parried=false
		actor.hurt_box_collision.disabled=false
		actor.clash_timer.start()
		
	else:
		pass
