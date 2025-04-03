extends LimboState

@export var actor : Node2D
@export var movement_handler : MovementHandler

func _enter() -> void:
	actor.animation_player.play("Staggered")
	actor.hb_collision.disabled=true
	actor.bt_player.blackboard.set_var("attack_mode", false)
	actor.parry_timer.start(3)
	actor.hurt_box.set_damage_mulitplyer(3)
	print("staggered")
	actor.movement_handler.active=false
	movement_handler.active=false
	actor.state="STAGGERED"
	
#func _update(delta: float) -> void:
	#print(actor.parry_timer.time_left)
	
func _exit() -> void:
	print("recovered")
	movement_handler.active=true
	actor.hurt_box.set_damage_mulitplyer(1)
