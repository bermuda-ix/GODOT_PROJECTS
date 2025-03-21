extends LimboState

@export var actor : Node2D

func _enter() -> void:
	actor.animation_player.play("Staggered")
	actor.hb_collison.disabled=true
	actor.bt_player.blackboard.set_var("attack_mode", false)
	actor.parry_timer.start(3)
	actor.hurt_box.set_damage_mulitplyer(3)
	print("staggered")
	actor.movement_handler.active=false
	
#func _update(delta: float) -> void:
	#print(actor.parry_timer.time_left)
	
func _exit() -> void:
	print("recovered")
	actor.hurt_box.set_damage_mulitplyer(1)
