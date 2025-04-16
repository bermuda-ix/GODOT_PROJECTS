class_name ShootAttackManager

extends Node

@export var actor : Node2D
@export var animation_player : AnimationPlayer
@export var turret : Turret
@export var reload_timer : int

func shoot():
	if turret.infinite_ammo:
		animation_player.stop()
		animation_player.play("shoot")
		actor.turret.shoot()
	else:
		if turret.ammo_count>0:
			animation_player.stop()
			animation_player.play("shoot")
			actor.turret.shoot()
			turret.ammo_count-=1
		else:
			
			if reload_timer>0:
				for i in reload_timer:
					animation_player.play("reload")
					print(i)
					await animation_player.animation_finished
					
			else:
				animation_player.play("reload")
				await animation_player.animation_finished
			turret.ammo_count=turret.max_ammo
	
func shoot_setup(value : float):
	turret.setup(value)
	
func rotate_turret():
	if turret.slow_track:
		turret.rotation=actor.rotation
	else:
		return
