class_name HurtBox
extends Area2D


signal received_damage(damage: int)
signal received_stagger_damage(damage: int)
signal got_hit(hitbox: HitBox)
signal bullet_hit(_damage: int)

signal parried()
signal weakpoint_hit()

signal launched(launch_strength : float)
signal knockback(launch_strength : float, knock_back_strength : float)

@export var health: Health
@export var stagger: Stagger
@export var dmg_mult : int = 1
@export var weakpoint : bool = false

@onready var total_damage : int = 0

@export var shielded : bool = false
@export var knockback_active : bool = true


func _ready():
	connect("area_entered", _on_area_entered)
	#connect("area_entered", _on_parried)
	connect("body_entered", _bullet_hit)
	connect("body_entered", _knocked_back_enemy_collision)

func _on_area_entered(hitbox: HitBox) -> void:
	if not hitbox.active:
		return
	elif shielded:
		return
	
	elif health.health<=0:
		return
	else:
		assert(shielded!=true)
		hitbox.active=false
		if hitbox != null:
			#print(hitbox.knock_back)
			#if hitbox.launch:
				#launched.emit(hitbox.launch_strength)
			if hitbox.knock_back:
				print_debug(hitbox.launch_strength, ", ", hitbox.knock_back_strength)
				knockback.emit(hitbox.launch_strength, hitbox.knock_back_strength)
		
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

	
	if stagger.stagger>0:
		stagger.stagger-=1
	else:
		stagger.stagger-=1
		health.health-=1
		
		print_debug(health.health)
		#received_damage.emit(_damage)
		bullet_hit.emit(_damage)
		received_damage.emit(_damage)
	_rigid_body.impact()
		

func _knocked_back_enemy_collision(_body : CharacterBody2D):
	var _launch_strength := 0
	if not knockback_active:
		return
	elif "knocked_back" in _body:
		if _body.knocked_back == false:
			return
		else:
			knockback.emit(_launch_strength, _body.velocity.x/2)
			#knockback.x=_rigid_body.velocity.x/2
			stagger.staggered.emit()
			Events.camera_shake.emit(2,20)
	pass

func set_damage_mulitplyer(value:int):
	dmg_mult=value

func get_damage_mulitplyer() -> int:
	return dmg_mult
