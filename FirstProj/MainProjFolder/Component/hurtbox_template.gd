class_name HurtBox
extends Area2D


signal received_damage(damage: int)
signal received_stagger_damage(damage: int)
signal got_hit(hitbox: HitBox)
signal bullet_hit(_damage: int)

signal parried()
signal weakpoint_hit()

signal launched()
signal knockback()

@export var health: Health
@export var stagger: Stagger
@export var dmg_mult : int = 1
@export var weakpoint : bool = false

func _ready():
	connect("area_entered", _on_area_entered)
	#connect("area_entered", _on_parried)
	connect("body_entered", _bullet_hit)

func _on_area_entered(hitbox: HitBox) -> void:
	
	if hitbox.launch:
		launched.emit()
	if hitbox.knock_back:
		knockback.emit()
	
	if health.health<=0:
		return
	if hitbox != null:
		if hitbox.is_in_group("spc_atk"):
			weakpoint_hit.emit()
		if hitbox.stagger_damage:
			stagger.stagger -= (hitbox.damage * dmg_mult)
			### Maybe add minimum health damage to stagger attacks?  
			#print_debug(hitbox.damage, " ",dmg_mult)
			#received_damage.emit(hitbox.damage)
			got_hit.emit(hitbox)
		else:
			health.health -= (hitbox.damage * dmg_mult)
			#print_debug(hitbox.damage, " ",dmg_mult)
			received_damage.emit(hitbox.damage)
			got_hit.emit(hitbox)

func _bullet_hit(_rigid_body : RigidBody2D) -> void:
	var _damage=1
	if health.health<=0:
		return

	_rigid_body.hard_impact()
	if stagger.stagger>0:
		stagger.stagger-=1
	else:
		health.set_health(health.health-1)
		received_damage.emit(_damage)
		bullet_hit.emit(_damage)
	_rigid_body.impact()
		
		


func set_damage_mulitplyer(value:int):
	dmg_mult=value

func get_damage_mulitplyer() -> int:
	return dmg_mult
