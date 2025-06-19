extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity

func _enter() -> void:
	anim_player.speed_scale=1
	anim_player.play("idle")
	pc.s_atk=false
	pc.counter_box_collision.disabled=true


func _exit() -> void:
	print("exiting idle")
