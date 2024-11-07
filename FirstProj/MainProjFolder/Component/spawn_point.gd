extends Node2D

@onready var spawn_timer = $SpawnTimer
@onready var enemy_cnt : int

@export var enemy = preload("res://chars/robot_enemy.tscn")

func _ready():
	spawn_timer.start()


func _on_spawn_timer_timeout():
	
	var enemy_inst = enemy.instantiate()
	var timer : float = randf_range(3,10)
	
	enemy_inst.global_position = Vector2(position.x, position.y)
	get_tree().current_scene.add_child(enemy_inst)
	enemy_cnt = get_tree().get_nodes_in_group("Enemy").size()
	print("enemy spawn :", enemy_cnt)
	spawn_timer.start(timer)
