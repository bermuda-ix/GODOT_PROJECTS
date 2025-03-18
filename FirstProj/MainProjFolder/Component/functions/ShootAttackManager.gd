class_name ShootAttackManager

extends Node

@export var actor : Node2D

func shoot():
	actor.animation_player.play("shoot")
	actor.turret.shoot()
