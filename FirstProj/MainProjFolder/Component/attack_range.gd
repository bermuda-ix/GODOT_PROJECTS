class_name AttackRange
extends Area2D

signal in_range()

func _ready():
	connect("area_entered", _on_in_range)

func _on_in_range(player: PlayerEntity) -> void:
	in_range.emit()
