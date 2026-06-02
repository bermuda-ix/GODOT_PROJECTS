extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity
@export var hurt_box : HurtBox
#@export var hurtbox : CollisionShape2D
@export var stagger : Stagger
@export var state_machine : LimboHSM
@export var dodge_buffer : Timer
@onready var dodge_chain : int = clampi(1, 1, 3)
var dodge_dist : float = 0.0
var counter_dist : float = 0.0
var dodge_speed : float = 1.0

@export  var dodge_velocity := Vector2(100.0, 0)
@export var dodge_pos_start := 0.0
@export var dodge_distance := 100.0
@export var dodge_min_dist := 25.0

func _enter() -> void:
	print_debug("dodging")
	
	anim_player.play(pc.dodge_anim_run+"_"+str(dodge_chain))
	pc.set_collision_mask_value(15, false)
	#pc.set_collision_layer_value(2, false)
	pc.counter_box_collision.disabled=false
	hurt_box.active=false
	#hurtbox.disabled=true
	#if pc.input_axis==0:
		#dodge_dist=pc.global_position.x+30*pc.face_dir
		#dodge_speed=7
	#else:
		#dodge_dist=pc.global_position.x+70*pc.input_axis
		#dodge_speed=5
	#counter_dist = pc.global_position.x-10*pc.face_dir
	
	if pc.input_axis==0:
		pc.velocity.x=dodge_velocity.x*pc.face_dir
	else:
		pc.velocity.x=dodge_velocity.x*pc.input_axis
	dodge_pos_start=pc.global_position.x
	#dodge_buffer.start(0.5)
	
	

func _update(delta: float) -> void:
	#pc.global_position.x=lerpf(pc.global_position.x, dodge_dist, dodge_speed*delta)
	if abs(pc.global_position.x-dodge_pos_start)>dodge_min_dist and\
	Input.is_action_just_released("Dodge"):
		dodge_blend()
	elif abs(pc.global_position.x-dodge_pos_start)>dodge_distance:
		pc.state_machine.dispatch(&"return_to_idle")
	#elif Input.is_action_just_pressed("attack") and dodge_buffer.is_stopped():
		#pc.state_machine.dispatch(&"dash_attack")
	#if Input.is_action_just_pressed("Dodge") and dodge_buffer.time_left<=0.95:
		#if stagger.stagger>1:
			#stagger.stagger-=1
			#pc.set_stagger()
		#if dodge_chain==3:
			#dodge_chain=1
		#else:
			#dodge_chain+=1
		#state_machine.dispatch(&"dodge_chain")
		#dodge_pos_start=pc.global_position.x
	#if pc.input_axis==0:
		#pc.global_position.x=lerpf(pc.global_position.x, dodge_dist, 0.2)
	

func _exit() -> void:
	pc.velocity.x=0
	#pc.counter_box_collision.disabled=true
	pc.counter_box_collision.call_deferred("set_disabled", true)
	pc.set_collision_mask_value(15, true)
	#pc.set_collision_layer_value(2, true)
	#hurtbox.call_deferred("set_disabled", false)
	#hurtbox.disabled=false
	hurt_box.active=true
	dodge_buffer.start(0.5)
	
func dodge_blend():
	var _current_dodge=anim_player.current_animation
	anim_player.play_section_with_markers(_current_dodge, "end")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name==(pc.dodge_anim_run+"_"+str(dodge_chain)):
		pc.state_machine.dispatch(&"return_to_idle")
		pc.set_collision_mask_value(15, true)
		#pc.set_collision_layer_value(2, true)


func _on_dodge_buffer_timeout() -> void:
	if pc.state_machine.get_active_state()==pc.dodge_state:
		return
	else:
		dodge_chain=1
