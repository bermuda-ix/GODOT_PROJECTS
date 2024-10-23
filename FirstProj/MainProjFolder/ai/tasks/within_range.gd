extends BTAction

@export var target_var := &"target"

@export var range = 20

func _tick(_delta: float) -> Status:
	
	var target: CharacterBody2D = blackboard.get_var(target_var)
	
	if target != null:
		var tar_pos = target.global_position
		var dir = agent.global_position.direction_to(tar_pos)
		
		if abs(agent.global_position.x - tar_pos.x) <= range:
			agent.move(dir.x, 0)
			#print("Attacking")
			return SUCCESS

	return FAILURE
	
	
