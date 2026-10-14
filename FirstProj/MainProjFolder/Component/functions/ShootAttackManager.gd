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

@export var reload_fast := true

signal reloading
signal reloading_done
signal ammo_empty
signal finished_shooting

#REFACTORED RELOADING. To be added to all actors
@export var refactored_reloading : bool = false
@export var reload_anim : StringName ="reload"


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
						#print_debug(i)
						await animation_player.animation_finished
						
						
				else:
					animation_player.play("reload")
					await animation_player.animation_finished
					
				reloading_done.emit()
				turret.ammo_count=turret.max_ammo
			else:
				reload()

func fire_missile():
	pass

func shoot_refactor():
	if turret.ammo_count <= 0:
		animation_player.stop()
		ammo_empty.emit()
		return
	turret.shoot()
	turret.ammo_count-=1

func rapid_shoot(_value: int):
	var i := 0
	while (i<_value and turret.ammo_count>0):
		animation_player.play("shoot_crouch")
		turret.ammo_count-=1
		await get_tree().create_timer(0.2).timeout
		i+=1
	animation_player.stop()
	finished_shooting.emit()
	return

func empty_clip():
	var i:=0
	
	while turret.ammo_count > 0:
		turret.shoot()
		turret.ammo_count-=1
		await get_tree().create_timer(0.1).timeout
	animation_player.stop()
	ammo_empty.emit()
	return

func reload():
	reloading.emit()
	if reload_fast:
		animation_player.play(reload_anim)
		await animation_player.animation_finished
		reloading_done.emit()
		turret.ammo_count=turret.max_ammo
	else:
		while turret.ammo_count<turret.max_ammo:
			animation_player.play(reload_anim)
			await animation_player.animation_finished
			turret.ammo_count+=1
		reloading_done.emit()
	
	
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
