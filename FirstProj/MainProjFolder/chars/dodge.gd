extends LimboState

@export var actor : Node2D
@export var bt_player : BTPlayer
@export var animation_player: AnimationPlayer



func _enter() -> void:
	#print("begin dodge")
	animation_player.play("dodge")
	actor.dodge_timer.start()
	actor.hurt_box_collision.disabled=true
	actor.hb_collision.disabled=true

func _exit() -> void:
	animation_player.stop()
	actor.hurt_box_collision.disabled=false
	actor.hb_collision.disabled=true
