class_name Staggered

extends LimboState

@export var actor : Node2D
@export var movement_handler : MovementHandler
@export var stagger : Stagger
@export var bt_player : BTPlayer
@export var movement_able : bool = true 
@export var vfx_player : AnimationPlayer
@export var hurt_box : HurtBox
@export var stagger_timer : Timer

func _enter() -> void:


	stagger_timer.start(3)
	if "hb_collision" in actor:
		actor.hb_collision.set_deferred("disabled", true)
	if "current_speed" in actor:
		actor.current_speed=0
	if "hurt_box_collision" in actor:
		actor.hurt_box_collision.set_deferred("disabled", false)
	if "knockback" in actor:
		if actor.player_right:
			actor.knockback.x=-200
		else:
			actor.knockback.x=200
	
	actor.animation_player.play("staggered")
	if vfx_player!=null:
		vfx_player.play("staggered_entered")
	#actor.hurt_box.set_damage_mulitplyer(3)
	
	if movement_able:
		actor.movement_handler.active=false
		movement_handler.active=false
	
	hurt_box.active=true
	

	#actor.state="STAGGERED"
	
func _update(delta: float) -> void:
	if "hb_collision" in actor:
		actor.hb_collision.set_deferred("disabled", true)
	if "velocity" in actor:
		actor.velocity.x=lerpf(actor.velocity.x, 0, 0.5)
	if movement_able:
		actor.movement_handler.active=false
		movement_handler.active=false
	
func _exit() -> void:

	if movement_able:
		movement_handler.active=true
	hurt_box.set_damage_mulitplyer(1)
	print_debug(stagger.max_stagger)
	await stagger.stagger_recover()
	assert(stagger.stagger!=0)
	if vfx_player!=null:
		vfx_player.call_deferred("stop")
