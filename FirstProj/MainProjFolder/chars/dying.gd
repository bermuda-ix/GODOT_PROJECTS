class_name dying extends BTState

@export var large_enemy := false
@export var actor : Node2D
@export var death_knockback := 500
@export var death_launch := -25

func _enter() -> void:
	if large_enemy:
		pass
	else:
		actor.knocked_back=true
		if actor.player_right:
			actor.knockback.x=-death_knockback
		else:
			actor.knockback.x=death_knockback
		actor.knockback.y=death_launch
	#print_debug("dying")
