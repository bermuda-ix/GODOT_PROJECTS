class_name ShootAttackManager

extends Node

@export var actor : Node2D
@export var turret : Turret

func shoot():
	actor.animation_player.play("shoot")
	actor.turret.shoot()

func shoot_setup(value : float):
	turret.setup(value)
