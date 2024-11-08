extends Node2D

@onready var spawn_timer = $SpawnTimer
@onready var enemy_cnt : int = 1
@onready var spawn_size : int = 1

@export var enemy : Array[PackedScene] = [preload("res://chars/robot_enemy.tscn")]

func _ready():
	spawn_timer.start()
	spawn_size = enemy.size()


func _on_spawn_timer_timeout():
	var spawn_ind
	
	if spawn_size >1:
		spawn_ind = randi_range(0, spawn_size-1)
	else:	
		spawn_ind = 0
		
	var enemy_inst = enemy[spawn_ind].instantiate()
	var timer : float = randf_range(3,10)
	
	enemy_inst.global_position = Vector2(position.x, position.y)
	get_tree().current_scene.add_child(enemy_inst)
	enemy_cnt = get_tree().get_nodes_in_group("Enemy").size()
	print("enemy spawn :", enemy_cnt)
	spawn_timer.start(timer)
