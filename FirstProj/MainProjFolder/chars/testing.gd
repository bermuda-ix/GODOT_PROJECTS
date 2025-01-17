extends CharacterBody2D

const SPEED = 3000.0
const JUMP_VELOCITY = -400.0
const CLOCKWISE=PI/2
const COUNTER_CLOCKWISE=-PI/2

@onready var player_tracking = $PlayerTrackerPivot/PlayerTracking

@onready var label = $Label




var current_speed : float = 40.0
var prev_speed : float = 40.0
var acceleration : float = 800.0
var player_found : bool = true
var player : PlayerEntity = null
var jump_velocity = JUMP_VELOCITY
var knockback : Vector2 = Vector2.ZERO
var parried : bool = false 
var attacking : bool = false
var next_y
var state
var distance
var dir : int = -1
var arc_vector
var target_direction
var movement
var target_right : bool = false
var rotate_around : bool = false

func _ready():
	position.y = -264
	position.x = 408
	player = get_tree().get_first_node_in_group("player")
	
	
func _process(delta):
	track_player()
	
	
	
	
func _physics_process(delta):
	handle_movement()
	
	
	if rotate_around:
		move_and_slide()
		velocity = movement * SPEED * delta

func track_player():
	
	var direction_to_player : Vector2 = Vector2(player.position.x, player.position.y)\
	- player_tracking.position
	arc_vector = Vector2(position-Vector2(player.position)).normalized()
			
	
	if not rotate_around:
		if arc_vector<Vector2.RIGHT and Vector2.UP<arc_vector:
			#movement = target_direction.rotated(COUNTER_CLOCKWISE)
			#print("on right")
			target_right = true
			
		elif arc_vector>Vector2.LEFT and Vector2.UP>arc_vector:
			#print("on left")
			target_right = false
			#movement = target_direction.rotated(CLOCKWISE)
	else:
		if target_right:
			#print(str(arc_vector), " ", Vector2.DOWN)
			if arc_vector.x<=-.9:
				rotate_around = false
				print("finished")
		else:
			if arc_vector.x>=.9:
				rotate_around = false
				print("finished")
	#arc_vector = Vector2(position-Vector2(player.position)).normalized()
	#print(direction_to_player.normalized())
	#print(arc_vector)

func handle_movement():
	distance=global_position.x-player.position.x
	label.text=str(abs(distance))
	target_direction = position.direction_to(player.position)
	
	label.text=str(abs(distance))
	if abs(distance)<25:
		rotate_around=true
		#print("arcing ", str(arc_vector))

		
	if not rotate_around :
		if position.x >= 400 and dir==1:
			dir = -1
		elif position.x <= 200 and dir==-1:
			dir = 1
		position.x += 1 * dir
	else:
		if target_right:
			movement = target_direction.rotated(CLOCKWISE)
		else:
			movement = target_direction.rotated(COUNTER_CLOCKWISE)


	
	
	
