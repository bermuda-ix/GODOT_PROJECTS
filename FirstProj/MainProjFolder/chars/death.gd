extends LimboState

@export var actor : Node2D

func _enter() -> void:
	actor.hb_collison.disabled=true
	actor.state="DEATH"
	actor.bt_player.blackboard.set_var("attack_mode", false)
	actor.hb_collision.disabled=true

func _update(delta: float) -> void:
	actor.hb_collison.disabled=true
	#print("oof i'm dead sadge")
	actor.movement_handler.active=false
	actor.animated_sprite_2d.scale.x = 1
