extends LimboState

@export var actor : Node2D

func _enter() -> void:
	actor.animation_player.play("Staggered")
	actor.hb_collison.disabled=true
	actor.bt_player.blackboard.set_var("attack_mode", false)
	actor.parry_timer.start(5)
	actor.hurt_box.set_damage_mulitplyer(3)
	print("staggered")
	actor.movement_handler.active=false

func _exit() -> void:
	actor.hurt_box.set_damage_mulitplyer(1)
