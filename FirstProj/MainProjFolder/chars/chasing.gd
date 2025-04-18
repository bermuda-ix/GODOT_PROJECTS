extends LimboState

@export var actor : Node2D
@export var bt_player : BTPlayer

func _enter() -> void:
	#print("begin chase")
	actor.player_found=true
	actor.hb_collision.disabled=true
	bt_player.blackboard.set_var("attack_mode", true)
	actor.animation_player.play("run")
