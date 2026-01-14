class_name enemy_list
extends Resource

#const MECH_ENEMY = preload("res://chars/mech_enemy.tscn")
#const ROBOT_ENEMY = preload("res://chars/robot_enemy.tscn")

#Regular enemies
const REG_ENEMIES = {
	FLYING_ENEMY = preload("res://chars/flying_enemy.tscn"),
	GUARD_ENEMY = preload("res://chars/guard_enemy.tscn"),
	}
#Elite Enemies
const ELITE_ENEMIES = {
	SOLDIER_ENEMY = preload("res://chars/soldier_enemy.tscn"),
	HEAVY_SOLDIER = preload("res://chars/heavy_soldier.tscn")
	}

#Bosses
@export_category("Bosses")
#const BOSS_ENEMY_BT = preload("res://chars/boss_enemy_bt.tscn")
const BOSSES = {
	MECH_RANGED = preload("res://chars/mech_ranged.tscn")
}
