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

signal riposte_follow_up
signal riposte_heavy_follow_up
signal nothing_follow_up

func _ready() -> void:
	Events.parry_success.connect(clash_follow_up)

func _enter() -> void:
	vfx_sprite.visible=true
	vfx_player.play(clash_anim_name)
	actor.current_speed=0
	hurt_box.shielded=false
	anim_player.pause()
	movement_handler.active=false
	actor.knockback=Vector2.ZERO
	#stagger.set_stagger(stagger.stagger-1)
	vfx_player.speed_scale=1/Engine.time_scale
	if stagger.stagger>counter_stagger_threshold and counter_enabled:
		stagger.stagger-=1
		counter_attack_timer.start(counter_attack_timer_dur)
	else:
		movement_handler.active=false

func _update(delta: float) -> void:
	#assert(not anim_player.is_playing())
	vfx_player.speed_scale=1/Engine.time_scale
	actor.velocity.x=0+actor.knockback.x
	#if actor.velocity.x!=0:
		#print_debug(actor.velocity.x)
	actor.velocity.y=0
	#actor.knockback=Vector2.ZERO
	#if actor.velocity.x!=0:
		#print_debug(actor.velocity.x)
	assert(vfx_player.is_playing())
	assert(vfx_sprite.visible)

func _exit() -> void:
	vfx_player.stop()
	vfx_sprite.visible=false
	hit_stop.end_hit_stop()
	if stagger.stagger<=0:
		if not movement_handler.active:
			movement_handler.active=true
		return
	


func clash_follow_up(_follow_up := "nothing"):
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
			if stagger.stagger<=1:
				dispatch(&"clash_fail")
		"nothing":
			nothing_follow_up.emit()
			actor.pushed_back(150)
			anim_player.play()
		
		_:
			anim_player.play()
