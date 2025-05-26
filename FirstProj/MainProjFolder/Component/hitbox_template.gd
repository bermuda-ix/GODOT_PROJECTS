class_name HitBox
extends Area2D

signal parried()

@export var damage: int = 1 : set = set_damage, get = get_damage
@export var stagger: Stagger

func _ready():
	connect("area_entered", _on_parried)

func set_damage(value: int):
	damage = value
	
func get_damage() -> int:
	return damage

func _on_parried(parrybox: ParryBox) -> void:
	if parrybox!= null:
		#print("parried!")
		stagger.stagger -= 1
		parried.emit()
