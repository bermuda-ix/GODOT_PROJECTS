class_name ShootAttackManager

extends Node

@export var actor : Node2D
@export var animation_player : AnimationPlayer
@export var turrets : Array[Turret]
@export var reload_timer : int
var turret_order : int =0


@export var linked : bool = false
@onready var shooting : bool = false

signal reloading
signal reloading_done

func shoot():
	if turrets.size()==1:
		if turrets[0].infinite_ammo:
			animation_player.stop()
			animation_player.play("shoot")
			turrets[0].shoot()
		else:
			if turrets[0].ammo_count>0:
				shooting=true
				animation_player.stop()
				animation_player.play("shoot")
				turrets[0].shoot()
				turrets[0].ammo_count-=1
				
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
				turrets[0].ammo_count=turrets[0].max_ammo
	
func shoot_setup(value : float):
	if turrets.size()==1:
		turrets[0].setup(value)
	
func rotate_turret():
	if turrets.size()==1:
		if turrets[0].slow_track:
			turrets[0].rotation=actor.rotation
		else:
			return

func staggerd_shoot():
	if not linked:
		return
