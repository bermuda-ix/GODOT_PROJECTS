class_name HurtBox
extends Area2D


signal received_damage(damage: int)
signal received_stagger_damage(damage: int)
signal got_hit(hitbox: HitBox)
signal bullet_hit(_damage: int)

signal parried()
signal weakpoint_hit()

signal launched(launch_strength : float)
signal knockback(knock_back_strength : float)

@export var health: Health
@export var stagger: Stagger
@export var dmg_mult : int = 1
@export var weakpoint : bool = false

@onready var total_damage : int = 0

@export var shielded : bool = false


func _ready():
	connect("area_entered", _on_area_entered)
	#connect("area_entered", _on_parried)
	connect("body_entered", _bullet_hit)

func _on_area_entered(hitbox: HitBox) -> void:
	
	if not hitbox.active:
		return
		
	
	elif health.health<=0:
		return
	else:
		if hitbox != null:
			#print(hitbox.knock_back)
			if hitbox.launch:
				launched.emit(hitbox.launch_strength)
			if hitbox.knock_back:
				#print("KNOCKING BACK")
				knockback.emit(hitbox.knock_back_strength)
		
			if hitbox.is_in_group("spc_atk"):
				weakpoint_hit.emit()
			if hitbox.stagger_damage:
				stagger.stagger -= (hitbox.damage * dmg_mult)
				### Maybe add minimum health damage to stagger attacks?  
				#print_debug(hitbox.damage, " ",dmg_mult)
				#received_damage.emit(hitbox.damage)
				got_hit.emit(hitbox)
			else:
				if weakpoint:
					health.health -= (hitbox.damage * dmg_mult)
					stagger.stagger -= (hitbox.damage * dmg_mult)
					#print_debug(hitbox.damage, " ",dmg_mult)
					received_damage.emit(hitbox.damage)
					got_hit.emit(hitbox)
				else:
					if not shielded:
						health.health -= (hitbox.damage * dmg_mult)
						#print_debug(hitbox.damage, " ",dmg_mult)
						received_damage.emit(hitbox.damage)
						got_hit.emit(hitbox)

func _bullet_hit(_rigid_body : RigidBody2D) -> void:
	var _damage : int 
	if _rigid_body.has_method("get_damage"):
		_damage=_rigid_body.get_damage()
	else:
		_damage=1
	if health.health<=0:
		return

	_rigid_body.hard_impact()
	
	#if bullet_hit_buffer.is_stopped():
		#bullet_hit_buffer.start()
		#total_damage+=_damage
	#else:
		#total_damage+=_damage
		#bullet_hit_buffer.start()
	
	if stagger.stagger>0:
		stagger.stagger-=1
	else:
		health.set_health(health.health-1)
		
		print_debug(health.health)
		#received_damage.emit(_damage)
		bullet_hit.emit(_damage)
		received_damage.emit(_damage)
	_rigid_body.impact()
		
		



func set_damage_mulitplyer(value:int):
	dmg_mult=value

func get_damage_mulitplyer() -> int:
	return dmg_mult

#
#func _on_bullet_hit_buffer_timeout() -> void:
	#if total_damage>=stagger.stagger:
		#var _damage_left=total_damage-stagger.stagger
		#stagger.stagger=0
		#health.health-=_damage_left
		#received_damage.emit(_damage_left)
		#print_debug("health left", health.health)
		#print_debug(total_damage)
	#elif total_damage<stagger.stagger:
		#stagger.stagger-=total_damage
		#print_debug(total_damage)
	#else:
		#health.health-=total_damage
		#received_damage.emit(total_damage)
		#print_debug(total_damage)
	#total_damage=0
