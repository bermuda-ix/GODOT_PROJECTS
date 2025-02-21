extends Node2D

@onready var spawn_timer = $SpawnTimer
@onready var enemy_cnt : int = 1
@onready var spawn_size : int = 1

@export var active : bool = true
@export var single_spawn : bool = true
@export var enemy : Array[PackedScene] = [enemy_list.ROBOT_ENEMY, enemy_list.FLYING_ENEMY]
@export var enemy_single : PackedScene
@export var max_enemy : int = 5
@export var spawn_type : String = "enemy"

func _ready():
	spawn_timer.start()
	spawn_size = enemy.size()
	Events.activate.connect(activate)
	Events.deactivate.connect(deactivate)
	Events.spawn_update.connect(spawn_update)

func _on_spawn_timer_timeout():
	var spawn_ind
	if active:
		if spawn_type=="boss":
			var enemy_inst = enemy[0].instantiate()
			enemy_inst.global_position = Vector2(position.x, position.y)
			get_tree().current_scene.add_child(enemy_inst)
			spawn_timer.paused=true
		
		elif single_spawn:
			var enemy_inst = enemy_single.instantiate()
			enemy_inst.global_position = Vector2(position.x, position.y)
			get_tree().current_scene.add_child(enemy_inst)
			active=false
		
		else:
			if enemy_cnt < max_enemy:
				if spawn_size >1:
					spawn_ind = randi_range(0, spawn_size-1)
				else:	
					spawn_ind = 0
					
				var enemy_inst = enemy[spawn_ind].instantiate()
				
			
				enemy_inst.global_position = Vector2(position.x, position.y)
				get_tree().current_scene.add_child(enemy_inst)
				
			else:
				print("max spawned")
				
			var timer : float = randf_range(3,10)
			enemy_cnt = get_tree().get_nodes_in_group("Enemy").size()
			print("enemy spawn :", enemy_cnt)
			spawn_timer.start(timer)
		
	else:
		pass

func activate(spawn):
	#print(spawn)
	if spawn==spawn_type:
		print("activate")
		spawn_timer.paused=false
		active=true
		
func deactivate(spawn):
	if spawn==spawn_type:
		print("deactivate")
		spawn_timer.paused=true
		active=false

func spawn_update(enemy_spawn, add : bool):
	if add:
		enemy.append(enemy_spawn)
		spawn_size = enemy.size()
	else:
		enemy.erase(enemy_spawn)
		spawn_size = enemy.size()
		
	print(enemy.size())
