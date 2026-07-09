extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity
@onready var attack_state: LimboHSM = $"."
@export var hit_box : HitBox
@export var slamming := false
var counter_dist
var starting : float
var lunge_distance := 500.0

func _enter() -> void:
	#print_debug("entering attack")
	pc.velocity=Vector2.ZERO
	counter_dist = pc.global_position.x-10*pc.face_dir
	#pc.attacking=true
	starting = pc.global_position.x
	hit_box.clash_active=true

	
func _update(delta: float) -> void:
	
	attack_lunge()
	pc.label.text=str(pc.velocity.x)
	if pc.state_machine.get_previous_active_state()==pc.dodge_state:
		pc.global_position.x=lerpf(pc.global_position.x, counter_dist, 0.2)
	
	if attack_state.get_active_state()==pc.slam_start:
		if pc.is_on_floor():
			attack_state.dispatch(&"slam_end")
	#assert(hit_box.clash_active!=hit_box.attack_clashed)
		

func _exit() -> void:
	pc.attack_timer.paused=false
	#pc.attacking=false
	hit_box.active=false
	#hit_box.clash_active=false

func attack_lunge() -> void:
	pc.move_and_slide()
	pc.velocity.x=lerpf(pc.velocity.x, 0, 0.5)


func attack_lunge_setup(_lunge_distance := 50.0) -> void:
	pc.velocity.x=_lunge_distance*-pc.face_dir
	starting = pc.global_position.x
	#lunge_distance=_lunge_distance

func attack_launch(_launch_distance := -25) -> void:
	pc.velocity.y+=_launch_distance
