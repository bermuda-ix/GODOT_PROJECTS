class_name EnemyGroup

extends Node


@export_category("HeavySoldier")
@export var heavy_soldier_enemies : Array[HeavySoldier]

@export_category("SoldierEnemy")
@export var soldier_enemies : Array[SoldierEnemy]

@export_category("GuardEnemy")
@export var guard_enemies : Array[GuardEnemy]

var all_grouped_enemies : Array[Node2D]

func _ready() -> void:
	all_grouped_enemies.append_array(heavy_soldier_enemies)
	all_grouped_enemies.append_array(soldier_enemies)
	all_grouped_enemies.append_array(guard_enemies)
	
	if all_grouped_enemies!=null:
		for i in range(all_grouped_enemies.size()):
			print(all_grouped_enemies[i].name, " linked")
