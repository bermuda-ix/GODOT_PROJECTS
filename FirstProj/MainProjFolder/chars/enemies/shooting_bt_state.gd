class_name ShootingBT extends BTState

@export var turret : Turret
@export var stagger : Stagger

func _ready() -> void:
	blackboard.bind_var_to_property("ammo", turret, "&ammo_count", true)
	blackboard.bind_var_to_property("stagger", stagger, "&stagger", true)

func _update(delta: float) -> void:
	blackboard.set_var("ammo", turret.ammo_count)
	blackboard.set_var("stagger", stagger.stagger)

func _debug_var() -> void:
	print(blackboard.get_var("ammo"))


func _on_shoot_attack_manager_reloading_done() -> void:
	blackboard.set_var("reloaded", true)


func _on_shoot_attack_manager_reloading() -> void:
	blackboard.set_var("reloaded", false)
