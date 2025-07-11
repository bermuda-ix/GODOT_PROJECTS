extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity
@onready var attack_state: LimboHSM = $"."
var counter_dist

func _enter() -> void:
	print("entering attack")
	counter_dist = pc.global_position.x-10*pc.face_dir

func _update(delta: float) -> void:
	
	
	if pc.state_machine.get_previous_active_state()==pc.dodge_state:
		pc.global_position.x=lerpf(pc.global_position.x, counter_dist, 0.2)

func _exit() -> void:
	pc.attack_timer.paused=false
	#print("exit attack")
