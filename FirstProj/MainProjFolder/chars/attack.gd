class_name Attack

extends LimboState

@export var actor : Node2D
@export var bt_player : BTPlayer
var starting : float
var lunge_distance := 0
var attack_dir := 1

func _enter() -> void:
	actor.state="ATTACK"
	if actor.player_right:
		attack_dir = 1
	else:
		attack_dir = -1
	starting = actor.global_position.x
	#print_debug("begin attack")
	#bt_player.blackboard.set_var("attack_mode", true)
func _update(delta: float) -> void:
	
	attack_lunge()
	
#func _exit() -> void:
	#print_debug("exit")

func attack_lunge() -> void:
	actor.global_position.x=lerpf(starting, actor.global_position.x+(lunge_distance*attack_dir), 0.5)

func attack_lunge_setup(_lunge_distance := 5.0) -> void:
	starting = actor.global_position.x
	lunge_distance=_lunge_distance
