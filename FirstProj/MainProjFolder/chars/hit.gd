class_name Hit

extends LimboState

@export var actor : Node2D
@export var hurtbox : HurtBox
@export var animation_player : AnimationPlayer
@export var hit_anim : String = "hit"



func _enter() -> void:
	actor.state="Hit"
	animation_player.play(hit_anim)

	
func _update(delta: float) -> void:
	actor.velocity.x=lerpf(actor.velocity.x, 0, 0.3)

func _exit() -> void:
	#print_debug("hit recovered")
	#actor.hurt_box_collision.disabled=false
	actor.hurt_box_collision.call_deferred("set_disabled", false)
	hurtbox.set_collision_layer_value(7, true)
	
	animation_player.play("RESET")
