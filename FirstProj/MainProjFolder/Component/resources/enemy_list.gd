class_name enemy_list
extends Resource

#const MECH_ENEMY = preload("res://chars/mech_enemy.tscn")
#const ROBOT_ENEMY = preload("res://chars/robot_enemy.tscn")

#Regular enemies
const REG_ENEMIES := {
	FLYING_ENEMY = preload("res://chars/flying_enemy.tscn"),
	GUARD_ENEMY = preload("res://chars/guard_enemy.tscn"),
	}
#Elite Enemies
const ELITE_ENEMIES := {
	SOLDIER_ENEMY = preload("res://chars/soldier_enemy.tscn"),
	HEAVY_SOLDIER = preload("res://chars/heavy_soldier.tscn"),
	ASSAULT_RIFLE_SOLDIER = preload("uid://bbkom6a7pabbe"),
	SHOTGUN_BULLET_ENEMY = preload("uid://bbjg0xw2unq4s")
	}

#Bosses
@export_category("Bosses")
#Preloaded
const BOSSES := {
	SHIELD_BOSS = preload("uid://c8aamv61i62mb")
}
#Nonloaded
const BOSS_REF := {
	"SOLDIER_BOSS" = "uid://cu7yn55uf2fn8",
	"MECH_RANGED" = "res://chars/mech_ranged.tscn",
	"DEMON_1" = "res://chars/demon_phase1.tscn",
	"SHIELD_BOSS" = "uid://c8aamv61i62mb"
	}
