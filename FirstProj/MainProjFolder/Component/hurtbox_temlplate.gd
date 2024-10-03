class_name HurtBox
extends Area2D


signal received_damage(damage: int)
signal got_hit()

@export var health: Health


func _ready():
	connect("area_entered", _on_area_entered)


func _on_area_entered(hitbox: HitBox) -> void:
	if hitbox != null:
		health.health -= hitbox.damage
		print(health.health)
		received_damage.emit(hitbox.damage)
		got_hit.emit()
