class_name Clashed extends LimboState

@export var actor : Node2D
@export var anim_player : AnimationPlayer
@export var vfx_player : AnimationPlayer
@export var hurt_box : HurtBox
@export var movement_handler : MovementHandler
@export var stagger : Stagger
@export var state_machine : LimboHSM
@export var hit_stop : HitStop
@export var clash_anim_name : StringName = "clashed"
@export_category("Counter Attack Properties")
@export var counter_attack_timer : Timer
@export var counter_stagger_threshold : int = 1
@export var counter_enabled : bool = false

func _enter() -> void:
	if vfx_player != null:
		if vfx_player.has_animation(clash_anim_name):
			vfx_player.play(clash_anim_name)
	#hit_stop.hit_stop(0.01, 0.25)
	#vfx_sprite.visible=true
	actor.current_speed=0
	hurt_box.shielded=false
	anim_player.pause()
	movement_handler.active=false
	actor.knockback=Vector2.ZERO
	#stagger.set_stagger(stagger.stagger-1)
	vfx_player.speed_scale=1/Engine.time_scale
	if stagger.stagger>counter_stagger_threshold and counter_enabled:
		counter_attack_timer.start(0.2)
	else:
		movement_handler.active=false

func _update(delta: float) -> void:
	vfx_player.speed_scale=1/Engine.time_scale
	actor.velocity.x=0+actor.knockback.x
	#if actor.velocity.x!=0:
		#print_debug(actor.velocity.x)
	actor.velocity.y=0
	#actor.knockback=Vector2.ZERO
	#if actor.velocity.x!=0:
		#print_debug(actor.velocity.x)
	#assert(vfx_player.is_playing())

func _exit() -> void:
	vfx_player.stop()
	hit_stop.end_hit_stop()
	if stagger.stagger<=0:
		if not movement_handler.active:
			movement_handler.active=true
		return
	if stagger.stagger<=0 and state_machine.get_active_state()!= actor.staggered:
		state_machine.dispatch(&"staggered")
	
