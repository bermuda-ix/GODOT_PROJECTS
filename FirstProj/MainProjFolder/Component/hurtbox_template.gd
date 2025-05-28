class_name HurtBox
extends Area2D


signal received_damage(damage: int)
signal got_hit(hitbox: HitBox)
signal knockback(hitbox: HitBox)
signal parried()
signal weakpoint_hit()

@export var health: Health
@export var stagger: Stagger
@export var dmg_mult : int = 1
@export var weakpoint : bool = false

func _ready():
	connect("area_entered", _on_area_entered)
	connect("area_entered", _on_parried)
	connect("area_entered", _on_weakpoint_hit)

func _on_area_entered(hitbox: HitBox) -> void:
	if hitbox != null:
		health.health -= (hitbox.damage * dmg_mult)
		#print(hitbox.damage, " ",dmg_mult)
		received_damage.emit(hitbox.damage)
		got_hit.emit(hitbox)
		
			
		

func _on_parried(parrybox: ParryBox) -> void:
	if parrybox!= null:
		parried.emit()

func _on_weakpoint_hit(area: Area2D) -> void:
	if area.is_in_group("spc_atk"):
		weakpoint_hit.emit()
		

func set_damage_mulitplyer(value:int):
	dmg_mult=value

func get_damage_mulitplyer() -> int:
	return dmg_mult
