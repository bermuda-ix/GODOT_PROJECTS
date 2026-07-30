class_name HitBox
extends Area2D

signal parried()
signal clashed()
signal clash_knock_back(_launch: float, _knockback : float, _impact_dir_right : bool)
signal clash_interrupt(_launch: float, _knockback : float, _impact_dir_right : bool, _damage : int)
signal hit_success


@export var damage: int = 1 : set = set_damage, get = get_damage
@export var stagger: Stagger
@export var stagger_damage : bool = false
@export var active : bool = false : set = set_active
@export var clash_active : bool = false : set = set_clash_active
@export var heavy_attack : bool = false : set = set_heavy_attack
@export var attack_clashed : bool = false

@export var launch : bool = false
@export var knock_back : bool = false
@export var launch_strength : float = 0.0
@export var knock_back_strength : float = 100.0

@export var pc_hitbos : bool = false

@onready var shield_hit : bool = false
@onready var impact_dir_right : bool = false

@onready var mutex : Mutex = Mutex.new()


@export var collision_shape : CollisionShape2D

func _ready():
	#connect("area_entered", _on_impact)
	area_entered.connect(_on_impact)
	#print_debug(get_groups())
	#collision_shape=get_tree().get_first_node_in_group("colliding_hitbox_shape")
	

func set_active(_value:bool)->void:
	active=_value
	if _value==true:
		pass
	elif _value==false:
		pass

func set_clash_active(_value: bool) -> void:
	clash_active=_value
	if _value==true:
		print_debug("attack_activate")
	elif _value==false:
		print_debug("attack_deactivate")
		
func set_heavy_attack(_value: bool) -> void:
	heavy_attack=_value
	#if _value==false:
		#print_debug("lower cause warcry")

func set_damage(value: int):
	damage = value
	
func get_damage() -> int:
	return damage

func refresh_collision() -> void:
	if attack_clashed:
		attack_clashed=false
		return
	clash_active=false
	if collision_shape.disabled==false:
		collision_shape.set_deferred("disabled", true)
		collision_shape.set_deferred("disabled", false)

func disable_collision(_value: bool = false) -> void:
	collision_shape.set_deferred("disabled", _value)

func _on_impact(_area :Area2D) -> void:
	mutex.lock()
	##############################################
	#Replace with bullet defelction once finished#
	##############################################
	if _area.is_in_group("bullet"):
		return
	
	if not clash_active:
		return
	
	if active and not heavy_attack:
		if _area.is_in_group("PlayerParryZone"):
			active=false
			#hit_dur.start(0.5)
	
	if _area!= null:
		
		if _area.is_in_group("hitbox"):
			_area.attack_clashed=true
			clash_active=false
			Events.hit_stop.emit(0.05, 0.5)
			if "heavy_attack" in _area:
				if _area.heavy_attack:
					if heavy_attack:
						clashed.emit()
					else:
						if _area.global_position.x > global_position.x:
							impact_dir_right=true
						else:
							impact_dir_right=false
						clash_interrupt.emit(_area.launch_strength, _area.knock_back_strength, impact_dir_right, _area.stagger_damage)
						Events.camera_shake.emit(3,20)
						_area.heavy_attack=false
				else:
					#pass
					#damage = 0
					if not _area.clash_active:
						return
					knock_back = false
					launch = false
					clashed.emit()
					Events.camera_shake.emit(0.5,10)
				
					
				#active=false
				
		elif _area.is_in_group("player_hitbox"):
			#print_debug("DERGH")
			assert(pc_hitbos==false)
			#damage = 0
			clash_active=false
			if _area.heavy_attack:
					if heavy_attack:
						clashed.emit()
					else:
						if _area.global_position.x > global_position.x:
							impact_dir_right=true
						else:
							impact_dir_right=false
						clash_interrupt.emit(_area.launch_strength, _area.knock_back_strength, impact_dir_right, _area.stagger_damage)
						#Events.camera_shake.emit(3,20)
						_area.heavy_attack=false
			else:
				knock_back = false
				launch = false
				attack_clashed=true
				if _area.knock_back:
					clash_knock_back.emit(_area.launch_strength, _area.knock_back_strength)
					#Events.camera_shake.emit(2,20)
				#elif _area.launch:
					#clash_launch.emit(40)
				else:
					
					clashed.emit()
			#active=false
		elif _area.is_in_group("ParryBox"):
			#print_debug("parried!")
			stagger.stagger -= 1
			parried.emit()
		else:
			#print_debug(_area.get_groups())
			pass
		#active=false
		if active:
			clash_active=false
			#active=false
			#if _area.is_in_group("regular_enemy_hb") or _area.is_in_group("player_hurtbox"):
				#active=false
	
	mutex.unlock()
