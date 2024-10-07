class_name ParryBox
extends Area2D

@export var knockback: Vector2 = Vector2.ZERO : set = set_knockback, get = get_knockback

func set_knockback(value: Vector2):
	knockback = value
	
func get_knockback() -> Vector2:
	return knockback
