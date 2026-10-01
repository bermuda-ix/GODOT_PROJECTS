class_name DyingState extends BTState

@export var large_enemy := false
@export var actor : Node2D
@export var death_knockback := 500
@export var death_launch := -25
@export var drop_handler : DropHandler
@export var hit_stop : HitStop

@onready var death_knockback_end : int = 0

func _enter() -> void:
	if large_enemy:
		pass
	else:
		actor.knocked_back=true
		if actor.player_right:
			actor.knockback.x=-death_knockback
			death_knockback_end=-death_knockback/4
		else:
			actor.knockback.x=death_knockback
			death_knockback_end=death_knockback/4
		actor.knockback.y=death_launch
	if "hb_collision" in actor:
		actor.hb_collision.set_deferred("disabled", true)
	if "hurt_box_collision" in actor:
		actor.hurt_box_collision.set_deferred("disabled", true)
	#Events.enemy_death.emit()
	drop_handler.spawn_drop()
	hit_stop.hit_stop(0.1, 0.3)
	actor.knockback.y=death_launch
	pass


func _update(delta: float) -> void:
	actor.velocity.x=lerpf(actor.velocity.x, death_knockback_end, 0.3)
	actor.velocity.y=lerpf(actor.velocity.y, 0, 0.3)
	if blackboard.get_var("hit_the_floor"):
		dispatch(&"success")
