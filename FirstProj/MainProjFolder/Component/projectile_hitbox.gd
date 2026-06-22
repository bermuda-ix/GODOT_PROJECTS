class_name ProjectileHitBox extends Area2D

@export var actor : Node2D
@export var impact_sfx : String =  SoundFx.SOCAPE_SMALL_KNOCK
@export var active : bool = true
@export var launch : bool = false
@export var knock_back : bool = false
@onready var stagger_damage : bool = false
@onready var damage : int = 1 : set = set_damage, get = get_damage


func _ready():
	#connect("area_entered", _projectile_impact)
	area_entered.connect(_projectile_impact)
	
func _projectile_impact( _area : Area2D):
	if _area.is_in_group("shield"):
		active=false
		pass
		
		#impact()
		#AudioStreamManager.play(impact_sfx)
	else:
		
		if _area.is_in_group("regular_enemy_hb") or _area.is_in_group("player_hurtbox"):
			if "active" in _area:
				if not _area.active:
					return
				else:
					#AudioStreamManager.play(impact_sfx)
					if "bullet_impact" in _area:
						_area.bullet_impact(1)
					elif "impact" in _area:
						actor.impact()
					else:
						pass
				active=false

func set_damage(value : int) -> void:
	damage=value

func get_damage() -> int:
	return damage
