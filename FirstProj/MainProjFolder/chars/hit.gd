class_name Hit

extends LimboState

@export var actor : Node2D
@export var animation_player : AnimationPlayer



func _enter() -> void:
	actor.state="Hit"
	#actor.bt_player.blackboard.set_var("attack_mode", false)
	#animation_player.stop()
	animation_player.play("hit")
	actor.hurt_box_collision.disabled=true
	
	
func _exit() -> void:
	#print("hit recovered")
	actor.hurt_box_collision.disabled=false
	animation_player.play("RESET")
