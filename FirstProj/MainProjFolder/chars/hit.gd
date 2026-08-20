class_name Hit

extends LimboState

@export var actor : Node2D
@export var hurtbox : HurtBox
@export var animation_player : AnimationPlayer
@export var hit_fx_player : AnimationPlayer
@export var hit_anim : String = "hit"
@export var hit_fx_anim : String ="hit"
@export var stagger : Stagger
@export var stagger_threshold : int = 3

signal stagger_threshold_reached

func _enter() -> void:
	actor.state="Hit"
	if stagger.stagger<=stagger_threshold:
		animation_player.play(hit_anim)
		stagger_threshold_reached.emit()
	else:
		if hit_fx_player.has_animation(hit_fx_anim):
			hit_fx_player.play(hit_fx_anim)

	
func _update(delta: float) -> void:
	actor.velocity.x=lerpf(actor.velocity.x, 0, 0.3)
	

func _exit() -> void:
	#print_debug("hit recovered")
	#actor.hurt_box_collision.disabled=false
	actor.hurt_box_collision.call_deferred("set_disabled", false)
	hurtbox.set_collision_layer_value(7, true)
	
	animation_player.play("RESET")
	
