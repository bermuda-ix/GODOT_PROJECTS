extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity
@onready var attack_state: LimboHSM = $"."
var counter_dist
var starting : float
var lunge_distance := 500.0

func _enter() -> void:
	#print_debug("entering attack")
	pc.velocity=Vector2.ZERO
	counter_dist = pc.global_position.x-10*pc.face_dir
	pc.attacking=true
	starting = pc.global_position.x

	
func _update(delta: float) -> void:
	
	attack_lunge()
	pc.label.text=str(pc.velocity.x)
	if pc.state_machine.get_previous_active_state()==pc.dodge_state:
		pc.global_position.x=lerpf(pc.global_position.x, counter_dist, 0.2)

func _exit() -> void:
	pc.attack_timer.paused=false
	pc.attacking=false

func attack_lunge() -> void:
	pc.move_and_slide()
	pc.velocity.x=lerpf(pc.velocity.x, 0, 0.5)

func attack_lunge_setup(_lunge_distance := 50.0) -> void:
	pc.velocity.x=lunge_distance*-pc.face_dir
	starting = pc.global_position.x
	lunge_distance=_lunge_distance
