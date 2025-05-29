extends LimboHSM

@export var actor : Node2D
@export var player_info : GetPlayerInfoHandler
@export var shoot_attack_handler : ShootAttackManager
@export var turret : Turret

func _enter() -> void:
	actor.state="SHOOTING"
	#
func _update(delta: float) -> void:
	#print(turret.ammo_count)
	if turret.ammo_count<=0:
		actor.shooting_states.dispatch(&"reload")
#
#
#func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	#if anim_name=="reload":
		#actor.shooting_states.dispatch(&"return_shooting")
