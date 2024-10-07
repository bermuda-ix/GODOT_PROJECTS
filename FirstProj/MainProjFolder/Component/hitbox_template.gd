class_name HitBox
extends Area2D

signal parried()

@export var damage: int = 1 : set = set_damage, get = get_damage

func _ready():
	connect("area_entered", _on_parried)

func set_damage(value: int):
	damage = value
	
func get_damage() -> int:
	return damage

func _on_parried(parrybox: ParryBox) -> void:
	if parrybox!= null:
		parried.emit()
