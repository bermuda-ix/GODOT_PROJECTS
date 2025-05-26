class_name Parry

extends LimboState

@export var actor : Node2D
@export var anim_player : AnimationPlayer
@export var timer : Timer


func _enter() -> void:
	#print("begin parry")
	actor.current_speed=0
	
