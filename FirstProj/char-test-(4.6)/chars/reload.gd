extends LimboState

@export var animation_player : AnimationPlayer
@export var turret : Turret


func _enter() -> void:
	animation_player.play("reload")

func _exit() -> void:
	turret.ammo_count=turret.max_ammo
