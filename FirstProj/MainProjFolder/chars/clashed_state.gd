class_name ClashedState extends LimboHSM

@export var actor : Node2D
@export var anim_player : AnimationPlayer
@export var vfx_player : AnimationPlayer
@export var vfx_sprite : AnimatedSprite2D
@export var hit_fx_player : AnimationPlayer
@export var hurt_box : HurtBox
@export var hit_box : HitBox
@export var hitbox_collision : CollisionShape2D
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
@onready var counter_queued := false

###States
@onready var clash_start: LimboState = $ClashStart
@onready var clash_counter: ClashCounter = $ClashCounter
@onready var clash_fail: ClashFail = $ClashFail
@onready var clash_heavy_counter: ClashHeavyCounterState = $ClashHeavyCounter
@onready var clash_dodge: ClashDodge = $ClashDodge



func set_clashes_made(_value : int) -> void:
	clashes_made=_value

signal riposte_follow_up
signal riposte_heavy_follow_up
signal nothing_follow_up

func _ready() -> void:
	_init_clash_state_machine()
	Events.parry_success.connect(clash_follow_up)
	counter_attack_timer.ignore_time_scale=true
	counter_attack_timer.one_shot=true

func _enter() -> void:
	actor.set_collision_mask_value(13, true)
	hit_box.in_clash_state=true
	actor.velocity.x=0
	vfx_sprite.visible=true
	vfx_player.play(clash_anim_name)
	actor.current_speed=0
	hurt_box.shielded=false
	anim_player.pause()
	movement_handler.active=false
	actor.knockback=Vector2.ZERO
	hitbox_collision.set_deferred("disabled", true)
	#stagger.set_stagger(stagger.stagger-1)
	vfx_player.speed_scale=1/Engine.time_scale
	if (clashes_made<counter_threshold and stagger.stagger>1) and counter_enabled:
		stagger.stagger-=1
		counter_attack_timer.start(counter_attack_timer_dur)
		hit_box.in_clash_state=false
		while counter_attack_timer.is_stopped():
			counter_attack_timer.start(counter_attack_timer_dur)
		assert(not counter_attack_timer.is_stopped())
		clashes_made+=1
	else:
		if counter_prepared:
			anim_player.play(&"preparing_counter")
			anim_player.pause()
			actor.set_collision_mask_value(13, false)
			while hurt_box.collision.disabled==true:
				hurt_box.collision.set_deferred("disabled", false)
		if stagger.stagger>1:
			actor.set_collision_mask_value(13, false)
			hit_fx_player.play("counter_prepared")
			while hurt_box.collision.disabled==true:
				hurt_box.collision.set_deferred("disabled", false)
			#hit_fx_player.play_section_with_markers("counter_prepared", "prepared")
			#hit_fx_player.pause()
		else:
			actor.set_collision_mask_value(13, true)
			anim_player.pause()
			assert(anim_player.is_playing()!=true)
			hitbox_collision.set_deferred("disabled", true)
			#hit_box.clash_active=false
		clashes_made==0
		movement_handler.active=false

func _update(delta: float) -> void:
	hitbox_collision.set_deferred("disabled", true)
	if get_active_state()==actor.clash_start:
		actor.velocity.x=0+actor.knockback.x
		actor.velocity.y=0
		#assert(actor.velocity.x==0)
		#assert(not anim_player.is_playing())
	vfx_player.speed_scale=1/Engine.time_scale
	

func _exit() -> void:
	vfx_player.stop()
	vfx_sprite.visible=false
	hit_stop.end_hit_stop()
	hit_box.attack_clashed=false
	if stagger.stagger<=0:
		if not movement_handler.active:
			movement_handler.active=true
		return
	


func clash_follow_up(_follow_up := "nothing"):
	vfx_sprite.visible=false
	vfx_player.stop()
	if state_machine.get_active_state()!=self:
		return
	match _follow_up:
		"riposte", "dodge":
			hitbox_collision.set_deferred("disabled", true)
			if stagger.stagger<=0:
				return
			anim_player.pause()
			hurt_box.active=true
			actor.pushed_back(250)
			stagger.stagger-=1
			if desperate_attack_enabled and stagger.stagger<=1:
				riposte_heavy_follow_up.emit()
				
			
			if stagger.stagger>0:
				if clashes_made<counter_threshold and counter_enabled:
					counter_queued
				riposte_follow_up.emit()
				#else:
					#state_machine.dispatch(&"hit")
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

func _init_clash_state_machine():
	initial_state=clash_start

	add_transition(clash_start, clash_fail, &"clash_fail")
	add_transition(clash_start, clash_counter, &"counter")
	add_transition(clash_start, clash_heavy_counter, &"clash_success")
	add_transition(clash_start, clash_dodge, &"clash_dodge")
