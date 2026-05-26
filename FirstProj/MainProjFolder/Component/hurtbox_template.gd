class_name HurtBox
extends Area2D


signal received_damage(damage: int)
signal received_stagger_damage(damage: int)
signal got_hit(hitbox: HitBox)
signal bullet_hit(_damage: int)

signal parried()
signal weakpoint_hit()

signal launched(launch_strength : float)
signal knockback(launch_strength : float, knock_back_strength : float, impact_dir_right : bool)

@export var health: Health
@export var stagger: Stagger
@export var back_attack_flag : RayCast2D
@export var dmg_mult : int = 1
@export var weakpoint : bool = false
@export var active : bool = true

@onready var total_damage : int = 0
@export var shielded : bool = false
@export var knockback_active : bool = true
@onready var impact_dir_right : bool = false
@onready var bullet_buffer : Timer = Timer.new()
@onready var bullet_damage : int = 0

func _ready():
	connect("area_entered", _on_area_entered)
	#connect("area_entered", _on_parried)
	connect("body_entered", _bullet_hit)
	connect("body_entered", _knocked_back_enemy_collision)
	
	add_child(bullet_buffer)
	bullet_buffer.autostart=false
	bullet_buffer.one_shot=true
	bullet_buffer.ignore_time_scale=true
	bullet_buffer.timeout.connect(bullet_buffer_timeout)

func _on_area_entered(hitbox: HitBox) -> void:
	if not hitbox.active:
		return
	elif not active:
		return
	elif shielded and not back_attack_flag.is_colliding():
		return
	
	elif health.health<=0:
		return
	else:
		assert(shielded!=true)
		#hitbox.active=false
		if hitbox != null:
			if stagger.stagger<=0:
				dmg_mult=3
			else:
				dmg_mult=1
			if hitbox.knock_back:
				if hitbox.global_position.x > global_position.x:
					impact_dir_right=true
				else:
					impact_dir_right=false
				print_debug(hitbox.launch_strength, ", ", hitbox.knock_back_strength)
				Events.camera_shake.emit(2,20)
				knockback.emit(hitbox.launch_strength, hitbox.knock_back_strength, impact_dir_right)
		
			if hitbox.is_in_group("spc_atk"):
				weakpoint_hit.emit()
			if hitbox.stagger_damage:
				stagger.stagger -= (hitbox.damage * dmg_mult)
				### Maybe add minimum health damage to stagger attacks?  

				got_hit.emit(hitbox)
			else:
				if weakpoint or back_attack_flag.is_colliding():
					health.health -= (hitbox.damage * dmg_mult)
					stagger.stagger -= (hitbox.damage * dmg_mult)
					received_damage.emit(hitbox.damage)
					got_hit.emit(hitbox)
					Events.camera_shake.emit(2,20)
				else:
					if not shielded:
						health.health -= (hitbox.damage * dmg_mult)
						received_damage.emit(hitbox.damage)
						got_hit.emit(hitbox)
						Events.camera_shake.emit(2,20)

func _bullet_hit(_rigid_body : RigidBody2D) -> void:
	
	pass
	
	#var _damage : int 
	#if _rigid_body.has_method("get_damage"):
		#_damage=_rigid_body.get_damage()
	#else:
		#_damage=1
	#if health.health<=0:
		#return
#
	#_rigid_body.hard_impact()
#
	#
	#if stagger.stagger>0:
		#stagger.stagger-=1
	#else:
		##stagger.stagger-=1
		#health.health-=1
		#
		#print_debug(health.health)
		##received_damage.emit(_damage)
		#bullet_hit.emit(_damage)
		#received_damage.emit(_damage)
	#_rigid_body.impact()
		

func bullet_impact(_damage : int = 1) -> void:
	if not active:
		return
	bullet_buffer.start(0.2)
	bullet_damage+=1

func _knocked_back_enemy_collision(_body : CharacterBody2D):
	var _launch_strength := 0
	if not knockback_active:
		return
	elif "knocked_back" in _body:
		if _body.knocked_back == false:
			return
		else:
			if _body.velocity.x >0:
				impact_dir_right=false
			else:
				impact_dir_right=true
			knockback.emit(_launch_strength, _body.velocity.x/2, impact_dir_right)
			#knockback.x=_rigid_body.velocity.x/2
			stagger.staggered.emit()
			Events.camera_shake.emit(2,20)
	pass

func set_damage_mulitplyer(value:int):
	dmg_mult=value

func get_damage_mulitplyer() -> int:
	return dmg_mult


func bullet_buffer_timeout() -> void:
	if stagger.stagger>0:
		if bullet_damage<=stagger.stagger:
			stagger.stagger-=bullet_damage
		else:
			stagger.set_stagger(0)
			var _left_over_damage = bullet_damage-stagger.stagger
			health.health-=_left_over_damage
			bullet_hit.emit(_left_over_damage)
			received_damage.emit(_left_over_damage)
			bullet_damage=0
	else:
		#stagger.stagger-=1
		health.set_health(health.health-bullet_damage)
		
		print_debug(health.health)
		#received_damage.emit(_damage)
		bullet_hit.emit(bullet_damage)
		received_damage.emit(bullet_damage)
		bullet_damage=0
