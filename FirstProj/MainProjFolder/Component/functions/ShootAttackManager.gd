class_name ShootAttackManager

extends Node

@export var actor : Node2D
@export var animation_player : AnimationPlayer
@export var turret : Turret
@export var reload_timer : int

@export var linked : bool = false
@onready var shooting : bool = false

signal reloading
signal reloading_done

func shoot():
	if turret.infinite_ammo:
		animation_player.stop()
		animation_player.play("shoot")
		actor.turret.shoot()
	else:
		if turret.ammo_count>0:
			shooting=true
			animation_player.stop()
			animation_player.play("shoot")
			actor.turret.shoot()
			turret.ammo_count-=1
			
		else:
			shooting=false
			reloading.emit()
			
			if reload_timer>0:
				for i in reload_timer:
					animation_player.play("reload")
					#print(i)
					await animation_player.animation_finished
					
					
			else:
				animation_player.play("reload")
				await animation_player.animation_finished
				
			reloading_done.emit()
			turret.ammo_count=turret.max_ammo
	
func shoot_setup(value : float):
	turret.setup(value)
	
func rotate_turret():
	if turret.slow_track:
		turret.rotation=actor.rotation
	else:
		return

func staggerd_shoot():
	if not linked:
		return
