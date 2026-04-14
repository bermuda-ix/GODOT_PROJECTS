class_name ProjectileHitBox extends Area2D

@export var actor : Node2D
@export var impact_sfx : String =  SoundFx.SOCAPE_SMALL_KNOCK

func _ready():
	connect("area_entered", _projectile_impact)
	
func _projectile_impact( _area : Area2D):
	if _area.is_in_group("shield"):
		#impact()
		AudioStreamManager.play(impact_sfx)
	else:
		AudioStreamManager.play(impact_sfx)
		if _area.is_in_group("regular_enemy_hb") or _area.is_in_group("player_hurtbox"):
			if "active" in _area:
				if not _area.active:
					return
				else:
					if "bullet_impact" in _area:
						_area.bullet_impact(1)
					actor.impact()
