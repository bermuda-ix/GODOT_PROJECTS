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
@export var active : bool = true : set = set_active

@onready var total_damage : int = 0
@export var shielded : bool = false
@export var knockback_active : bool = true
@onready var impact_dir_right : bool = false
@onready var bullet_buffer : Timer = Timer.new()
@onready var bullet_damage : int = 0

@onready var mutex : Mutex = Mutex.new()

func set_active(_value: bool) -> void:
	active=_value
	if _value==true:
		pass
	else:
		pass

func _ready():
	#connect("area_entered", _on_area_entered)
	area_entered.connect( _on_area_entered)
	#connect("area_entered", _on_parried)
	#connect("body_entered", _bullet_hit)
	#connect("body_entered", _knocked_back_enemy_collision)
	body_entered.connect(_knocked_back_enemy_collision)
	
	add_child(bullet_buffer)
	bullet_buffer.autostart=false
	bullet_buffer.one_shot=true
	bullet_buffer.ignore_time_scale=true
	bullet_buffer.timeout.connect(bullet_buffer_timeout)

func _on_area_entered(hitbox: Area2D) -> void:
	mutex.lock()
	#print_debug("area=", hitbox)
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
		hitbox.active=false
		if hitbox != null:
			if stagger.stagger<=0:
				dmg_mult=3
			else:
				dmg_mult=1
			#############################################
			#Replace with bullet knockback once finished#
			#############################################
			if hitbox.is_in_group("bullet") or hitbox.is_in_group("PlayerBullet"):
				#return
				if not active:
					return
				bullet_buffer.start(0.2)
				bullet_damage+=1
			
			elif hitbox.is_in_group("hitbox") or hitbox.is_in_group("player_hitbox"):
				if hitbox.knock_back:
					if hitbox.global_position.x > global_position.x:
						impact_dir_right=true
					else:
						impact_dir_right=false
					#print_debug(hitbox.launch_strength, ", ", hitbox.knock_back_strength)
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
						weakpoint_hit.emit()
						Events.camera_shake.emit(2,20)
					else:
						if not shielded:
							health.health -= (hitbox.damage * dmg_mult)
							#print_debug(hitbox.damage)
							received_damage.emit(hitbox.damage)
							
							got_hit.emit(hitbox)
							Events.camera_shake.emit(2,20)
	
	mutex.unlock()
func hitbox_collision():
	pass

func bullet_impact(_damage : int = 1) -> void:
	if not active:
		return
	bullet_buffer.start(0.2)
	bullet_damage+=1

func _knocked_back_enemy_collision(_body : Node2D):
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
		
func hit_sfx() -> void:
	pass
	#hit_buffer.start(1)
	#hit_sound=hit1
	#AudioStreamManager.play(hit_sound)
