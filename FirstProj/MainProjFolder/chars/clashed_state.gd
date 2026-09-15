class_name ClashedState extends LimboHSM

@export var actor : Node2D
@export var anim_player : AnimationPlayer
@export var vfx_player : AnimationPlayer
@export var vfx_sprite : AnimatedSprite2D
@export var hurt_box : HurtBox
@export var movement_handler : MovementHandler
@export var stagger : Stagger
@export var hit_stop : HitStop
@export var clash_anim_name : StringName = "clashed"
@export var state_machine : LimboHSM
@export_category("Counter Attack Properties")
@export var counter_attack_timer : Timer
@export var counter_attack_timer_dur := 0.2
@export var counter_stagger_threshold : int = 1
@export var counter_enabled : bool = false
@export var desperate_attack_enabled := false
@export var counter_threshold := 3
@onready var clashes_made := 0
@export var counter_prepared := false


signal riposte_follow_up
signal riposte_heavy_follow_up
signal nothing_follow_up

func _ready() -> void:
	Events.parry_success.connect(clash_follow_up)
	counter_attack_timer.ignore_time_scale=true
	counter_attack_timer.one_shot=true

func _enter() -> void:
	actor.velocity.x=0
	vfx_sprite.visible=true
	vfx_player.play(clash_anim_name)
	actor.current_speed=0
	hurt_box.shielded=false
	anim_player.pause()
	movement_handler.active=false
	actor.knockback=Vector2.ZERO
	#stagger.set_stagger(stagger.stagger-1)
	vfx_player.speed_scale=1/Engine.time_scale
	if clashes_made<counter_threshold and counter_enabled:
		stagger.stagger-=1
		counter_attack_timer.start(counter_attack_timer_dur)
		clashes_made+=1
	else:
		if counter_prepared:
			anim_player.play(&"preparing_counter")
			anim_player.pause()
		clashes_made==0
		movement_handler.active=false

func _update(delta: float) -> void:
	vfx_player.speed_scale=1/Engine.time_scale
	if get_active_state()==actor.clash_start:
		actor.velocity.x=0+actor.knockback.x
		actor.velocity.y=0

func _exit() -> void:
	vfx_player.stop()
	vfx_sprite.visible=false
	hit_stop.end_hit_stop()
	if stagger.stagger<=0:
		if not movement_handler.active:
			movement_handler.active=true
		return
	


func clash_follow_up(_follow_up := "nothing"):
	vfx_sprite.visible=false
	vfx_player.stop()
	match _follow_up:
		"riposte":
			if stagger.stagger<=0:
				return
			anim_player.play()
			actor.pushed_back(250)
			if desperate_attack_enabled and stagger.stagger==1:
				riposte_heavy_follow_up.emit()
			else:
				stagger.stagger-=1
				riposte_follow_up.emit()
			if stagger.stagger>0:
				state_machine.dispatch(&"hit")
			else:
				state_machine.dispatch(&"staggered")
		"heavy_riposte":
			riposte_heavy_follow_up.emit()
			if not counter_prepared:
				if stagger.stagger<=1:
					dispatch(&"clash_fail")
				else:
					dispatch(&"clash_dodge")
			else:
				dispatch(&"clash_success")
		"nothing":
			nothing_follow_up.emit()
			actor.pushed_back(150)
			anim_player.play()
		
		_:
			anim_player.play()
