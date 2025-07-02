class_name ShootAttackManager

extends Node

@export var actor : Node2D
@export var animation_player : AnimationPlayer
@export var turret : Turret
@export var reload_timer : int
var turret_order : int =0

@export var multi_wield : bool = false
@export var linked : bool = false
@onready var shooting : bool = false

signal reloading
signal reloading_done

#REFACTORED RELOADING. To be added to all actors
@export var refactored_reloading : bool = false

func shoot():
	if turret.infinite_ammo:
		if not multi_wield:
			animation_player.stop()
			animation_player.play("shoot")
		turret.shoot()
	else:
		if turret.ammo_count>0:
			shooting=true
			if not multi_wield:
				animation_player.stop()
				animation_player.play("shoot")
			turret.shoot()
			turret.ammo_count-=1
			
		else:
			if not refactored_reloading:
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
			else:
				pass
func fire_missile():
	pass

func shoot_refactor():
	turret.shoot()
	turret.ammo_count-=1

func reload():
	animation_player.play("reload")
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
