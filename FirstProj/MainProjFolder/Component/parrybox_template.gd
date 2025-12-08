class_name ParryBox
extends Area2D

signal parried_success()
signal bullet_stopped()

@export var knockback: Vector2 = Vector2.ZERO : set = set_knockback, get = get_knockback

func _ready() -> void:
	connect("area_entered", _on_parried)
	connect("body_entered", _bullet_stopped)

func set_knockback(value: Vector2):
	knockback = value
	
func get_knockback() -> Vector2:
	return knockback

func _on_parried(hitbox : HitBox) -> void:
	if hitbox!= null:
		#print("parried!")
		#stagger.stagger -= 1
		parried_success.emit()

func _bullet_stopped(_rigid_body : RigidBody2D) -> void:
	if _rigid_body.is_in_group("PlayerBullet"):
		_rigid_body.hard_impact()
		bullet_stopped.emit()
