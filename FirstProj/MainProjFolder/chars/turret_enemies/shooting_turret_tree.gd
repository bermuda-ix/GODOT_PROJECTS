extends BTState

@export var turret : Turret

func _update(delta: float) -> void:
	blackboard.set_var("ammo_amount", turret.ammo_count)
