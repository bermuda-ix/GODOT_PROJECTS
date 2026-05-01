extends Node2D

@export var boss : PackedScene
@export var active := true

func respawn_boss():
	if active==false:
		return
	else:
		var _boss_inst := boss.instantiate()
		_boss_inst.global_position=global_position
		return _boss_inst

func defeated() -> void:
	set_active(false)
	
func set_active(value : bool) -> void:
	active=value


func _on_local_flag_flag_triggered() -> void:
	active=true

func manual_spawn_boss() -> void:
	var _boss_inst := boss.instantiate()
	add_child(_boss_inst)
	_boss_inst.global_position=global_position
	_boss_inst.boss_activate()
