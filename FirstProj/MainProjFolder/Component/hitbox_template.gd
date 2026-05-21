class_name HitBox
extends Area2D

signal parried()
signal clashed()
signal clash_knock_back(_launch: float, _knockback : float, _impact_dir_right : bool)
signal clash_interrupt(_launch: float, _knockback : float, _impact_dir_right : bool, _damage : int)


@export var damage: int = 1 : set = set_damage, get = get_damage
@export var stagger: Stagger
@export var stagger_damage : bool = false
@export var active : bool = false : set = set_active
@export var heavy_attack : bool = false

@export var launch : bool = false
@export var knock_back : bool = false
@export var launch_strength : float = 0.0
@export var knock_back_strength : float = 100.0

@onready var shield_hit : bool = false
@onready var impact_dir_right : bool = false


func _ready():
	connect("area_entered", _on_parried)

func set_active(_value:bool)->void:
	active=_value

func set_damage(value: int):
	damage = value
	
func get_damage() -> int:
	return damage

func _on_parried(_area :Area2D) -> void:
	
	if _area!= null:
		if _area.is_in_group("hitbox"):
			if "active" in _area:
				_area.active=false
			if "heavy_attack" in _area:
				if _area.heavy_attack:
					if _area.global_position.x > global_position.x:
						impact_dir_right=true
					else:
						impact_dir_right=false
					clash_interrupt.emit(_area.launch_strength, _area.knock_back_strength, impact_dir_right, _area.stagger_damage)
					Events.camera_shake.emit(3,20)
					_area.heavy_attack=false
				else:
					pass
			damage = 0
			knock_back = false
			launch = false
			clashed.emit()
			Events.camera_shake.emit(0.5,10)
		elif _area.is_in_group("player_hitbox"):
			if "active" in _area:
				if _area.active==false:
					return
				else:
					_area.active=false
			#active=false
			damage = 0
			knock_back = false
			launch = false
			if _area.knock_back:
				clash_knock_back.emit(_area.launch_strength, _area.knock_back_strength)
				Events.camera_shake.emit(2,20)
			#elif _area.launch:
				#clash_launch.emit(40)
			else:
				active=false
				clashed.emit()
		elif _area.is_in_group("ParryBox"):
			#print_debug("parried!")
			stagger.stagger -= 1
			parried.emit()
		else:
			pass
