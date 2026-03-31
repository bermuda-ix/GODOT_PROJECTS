class_name HitBox
extends Area2D

signal parried()
signal clashed()
signal clash_launch(_launch: float)
signal clash_knock_back(_launch: float, _knockback : float)

@export var damage: int = 1 : set = set_damage, get = get_damage
@export var stagger: Stagger
@export var stagger_damage : bool = false
@export var active : bool = false : set = set_active


@export var launch : bool = false
@export var knock_back : bool = false
@export var launch_strength : float = 40.0
@export var knock_back_strength : float = 100.0

@onready var shield_hit : bool = false


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
		if _area.is_in_group("regular_enemy_hb"):
			active=false
			damage = 0
			knock_back = false
			launch = false
			clashed.emit()
		elif _area.is_in_group("player_hitbox"):
			active=false
			damage = 0
			knock_back = false
			launch = false
			if _area.knock_back:
				clash_knock_back.emit(_area.launch_strength, _area.knock_back_strength)
			#elif _area.launch:
				#clash_launch.emit(40)
			else:
				clashed.emit()
		elif _area.is_in_group("ParryBox"):
			#print_debug("parried!")
			stagger.stagger -= 1
			parried.emit()
		else:
			pass
