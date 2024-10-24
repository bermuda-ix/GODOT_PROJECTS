extends BTAction

@export var target_var := &"target"

@export var speed_var = 60
@export var tolerance = 250
@export var max_range = 300

func _tick(_delta: float) -> Status:
	
	var target: CharacterBody2D = blackboard.get_var(target_var)
	
	if target != null:
		var tar_pos = target.global_position
		var dir = agent.global_position.direction_to(tar_pos)
		#print(agent.global_position.x - tar_pos.x)
		var player_pos = abs(agent.global_position.x - tar_pos.x)
		
		if player_pos > tolerance and player_pos < max_range:
			agent.move(dir.x, 0)
			
			#print("In Range")
			return SUCCESS
		else:
			if player_pos > max_range:
				agent.move(dir.x, speed_var)
			#print("Chasing Playe")
			elif player_pos < tolerance:
				agent.move(dir.x, -speed_var)
			return RUNNING
	
	return FAILURE
