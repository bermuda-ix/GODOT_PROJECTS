extends LimboState

@export var anim_player : AnimationPlayer
@export var shotty_anim_player : AnimationPlayer
@export var pc : PlayerEntity
@onready var combo_type : int = 0 : set = set_combo_type
@onready var slow_down : bool : set = set_slow_down

func set_combo_type(_value : int) -> void:
	if combo_type!=0 and _value==0:
		pass
	combo_type=_value

func set_slow_down(_value : bool) -> void:
	slow_down=_value

func _enter() -> void:
	anim_player.speed_scale=1
	match combo_type:
		0:
			anim_player.play("shotgun_attack_fast")
		1, 2, 3, 4:
			slow_down=true
			shotty_anim_player.play("shotgun_aim_quick")
	
func _exit() -> void:
	pc.attacking=false
