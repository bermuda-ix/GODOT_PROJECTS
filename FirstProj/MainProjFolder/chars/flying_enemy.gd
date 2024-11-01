extends CharacterBody2D

const SPEED = 40

@export var player : PlayerEntity
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var player_tracker_pivot = $PlayerTrackerPivot
@onready var player_tracking = $PlayerTrackerPivot/PlayerTracking
@onready var jump_timer = $JumpTimer
@onready var parry_timer = $ParryTimer
@onready var chase_timer = $ChaseTimer

var player_found : bool = false

enum States{
	WANDER,
	CHASE,
	JUMP,
	ATTACK,
	PARRY
}
var current_state = States.WANDER
var prev_state = States.WANDER

func _process(delta):
	track_player()
	handle_vision()
	print(current_state)
	
func _physics_process(delta):
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = dir * SPEED
	
	if current_state==States.CHASE:
		move_and_slide()
	
	#makepath()
	
	
func makepath() -> void:
	nav_agent.target_position = player.global_position

func handle_vision():
	if player_tracking.is_colliding():
		var collision_result = player_tracking.get_collider()
		
		if collision_result != player:
			return
		else:
			set_state(current_state, States.CHASE)
			#chase_timer.start(1)
			player_found = true
			print("found")
			
	else:
		player_found = false
		
func track_player():
	if player == null:
		return
	
	var direction_to_player : Vector2 = Vector2(player.position.x, player.position.y)\
	- player_tracking.position
	
	player_tracker_pivot.look_at(direction_to_player)


func _on_nav_timer_timeout():
	makepath()

func set_state(cur_state, new_state) -> void:
	var state
	if(cur_state == new_state):
		pass
	#elif new_state==States.ATTACK and cur_state==States.JUMP:
		#cur_state="AIR_ATTACK"
		#anim_player.play(attack_combo)
	else:
		current_state = new_state
		prev_state = cur_state
		
		match current_state:
			States.ATTACK:
				state="ATTACK"
				
				
				#gravity=0
			States.WANDER:
				state="WANDER"
				
			States.CHASE:
				
				state="CHASE"
				
			States.JUMP:
				pass
			States.PARRY:
				pass
			States.ATTACK:
				pass
				#animation_player.play("attack")
				#await animation_player.animation_finished
		
		print(state)
