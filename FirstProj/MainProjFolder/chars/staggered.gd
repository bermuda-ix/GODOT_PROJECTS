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
	actor.hb_collision.set_deferred("disabled", true)
	actor.current_speed=0
	actor.velocity.x=0
	
	actor.animation_player.play("staggered")
	vfx_player.play("staggered_entered")
	actor.hurt_box.set_damage_mulitplyer(3)
	
	if movement_able:
		actor.movement_handler.active=false
		movement_handler.active=false
	
	hurt_box.active=true
	actor.hurt_box_collision.set_deferred("disabled", false)
	if actor.player_right:
		actor.knockback.x=-200
	else:
		actor.knockback.x=200
	#actor.state="STAGGERED"
	
func _update(delta: float) -> void:
	actor.hb_collision.set_deferred("disabled", true)
	actor.velocity.x=lerpf(actor.velocity.x, 0, 0.5)
	if movement_able:
		actor.movement_handler.active=false
		movement_handler.active=false
	
func _exit() -> void:

	if movement_able:
		movement_handler.active=true
	actor.hurt_box.set_damage_mulitplyer(1)
	stagger.stagger = stagger.max_stagger
	vfx_player.call_deferred("stop")
