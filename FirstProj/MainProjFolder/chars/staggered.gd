class_name Staggered

extends LimboState

@export var actor : Node2D
@export var movement_handler : MovementHandler
@export var stagger : Stagger
@export var bt_player : BTPlayer
@export var movement_able : bool = true 

func _enter() -> void:
	actor.animation_player.stop()
	actor.animation_player.play("Staggered")
	#actor.hb_collision.disabled=true
	actor.bt_player.blackboard.set_var("staggered", true)
	#actor.parry_timer.start(3)
	actor.hurt_box.set_damage_mulitplyer(3)
	print("staggered")
	
	if movement_able:
		actor.movement_handler.active=false
		movement_handler.active=false
	
	#actor.state="STAGGERED"
	
func _update(delta: float) -> void:
	print(actor.parry_timer.time_left)
	
func _exit() -> void:
	print("recovered")
	actor.bt_player.blackboard.set_var("staggered", false)
	if movement_able:
		movement_handler.active=true
	actor.hurt_box.set_damage_mulitplyer(1)
	stagger.stagger = stagger.max_stagger
