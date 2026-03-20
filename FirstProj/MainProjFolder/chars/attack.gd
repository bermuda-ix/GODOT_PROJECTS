class_name Attack

extends LimboState

@export var actor : Node2D
@export var bt_player : BTPlayer
var starting : float
var lunge_distance := 0
var attack_dir := 1

func _enter() -> void:
	actor.state="ATTACK"
	actor.velocity= Vector2.ZERO
	if actor.player_right:
		attack_dir = 1
	else:
		attack_dir = -1
	starting = actor.global_position.x
	#print_debug("begin attack")
	#bt_player.blackboard.set_var("attack_mode", true)
func _update(delta: float) -> void:
	
	attack_lunge()
	#print_debug(actor.velocity.x)
	
#func _exit() -> void:
	#print_debug("exit")
func attack_lunge() -> void:
	actor.move_and_slide()
	actor.velocity.x=lerpf(actor.velocity.x, 0, 0.5)

func attack_jump() -> void:
	actor.velocity.y=lerpf(actor.velocity.y, 0, 0.5)

func attack_lunge_setup(_lunge_distance := 200.0) -> void:
	starting = actor.global_position.x
	#lunge_distance=_lunge_distance
	actor.velocity.x=_lunge_distance*attack_dir

func attack_jump_setup(_jump_height := 50) -> void:
	actor.velocity.y=-_jump_height
