class_name AlertHandler extends Node

@export var all_enemies_alerted := false

func alert_enemies() -> void:
	var _enemies = get_tree().get_nodes_in_group("Enemy")
	if all_enemies_alerted:
		for _enemy in range(_enemies.size()-1, 0, -1):
			if "alerted" in _enemies[_enemy]:
				_enemies[_enemy].alerted()
