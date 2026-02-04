extends Node2D

class_name SpawnPoint

@onready var spawn_timer = $SpawnTimer
@onready var enemy_cnt : int = 1
@onready var spawn_size : int = 1
@onready var boss_spawn_size : int = 1
@onready var boss_rand : bool = false
var level_node

@export var active : bool = true
@export var single_spawn : bool = true
@onready var enemies : enemy_list
@export var enemy : Array[PackedScene] = []
@export var enemy_single : PackedScene
@export var boss_enemy : PackedScene
@export var max_enemy : int = 2
@export var spawn_type : String = "enemy"
@onready var current_heat : int = 0

#Limits
@export var limit_spawn : bool = false
@export var no_spawn_entered : bool = false
@export var spawn_pos_limit_upper : Vector2 = Vector2.ZERO
@export var spawn_pos_limit_lower : Vector2 = Vector2.ZERO
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var area_colliding := false
@onready var body_colliding := false

#initial spawn behavior
@export var spawn_active : bool = true

func _ready():
	spawn_timer.start()
	spawn_size = enemy.size()
	boss_spawn_size = enemies.BOSSES.size()
	level_node=get_tree().get_first_node_in_group("world").get_path()
	#print(level_node)
	
	if not single_spawn:
		Events.activate.connect(activate)
		Events.deactivate.connect(deactivate)
		Events.spawn_update.connect(spawn_update)
		Events.increase_heat_lvl.connect(heat_increased)
		Events.reset_heat.connect(reset_heat)

#func load_enemies():
	#match
	#
#func load_elite_enemies():
	#
#

func _on_spawn_timer_timeout():
	
	
	var spawn_ind
	var enemy_inst
	if limit_spawn:
		if global_position.x<spawn_pos_limit_lower.x or global_position.x>spawn_pos_limit_upper.x \
		or global_position.y<spawn_pos_limit_lower.y or global_position.y>spawn_pos_limit_upper.y:
			return
		else:
			pass
			
	if not active:
		return
	elif no_spawn_entered or area_colliding or body_colliding:
		return
	else:
		assert(no_spawn_entered!=true)
		assert(area_colliding!=true)
		assert(body_colliding!=true)
		if spawn_type=="boss":
			if boss_rand:
				enemy_inst = enemies.BOSSES[randi_range(1,boss_spawn_size-1)]
			else:
				enemy_inst = boss_enemy
			enemy_inst.global_position = Vector2(position.x, position.y)
			get_tree().get_root().get_node(level_node).add_child(enemy_inst)
			spawn_timer.paused=true
		
		elif single_spawn:
			enemy_inst = enemy_single.instantiate()
			enemy_inst.global_position = Vector2(position.x, position.y)
			if spawn_active:
				enemy_inst.always_active=true
			get_tree().get_root().get_node(level_node).add_child(enemy_inst)
			active=false
			
		
		else:
			if enemy.is_empty():
				return
			if enemy_cnt < max_enemy:
				if spawn_size >1:
					spawn_ind = randi_range(0, spawn_size-1)
				else:	
					spawn_ind = 0
					
				#var enemy_inst = enemy[spawn_ind].instantiate()
				enemy_inst = enemy[spawn_ind].instantiate()
				
			
				enemy_inst.global_position = Vector2(global_position.x, global_position.y)
				#enemy_inst.scale*=0.5
				if spawn_active:
					enemy_inst.always_active=true
				get_tree().get_root().get_node(level_node).add_child(enemy_inst)
				
			else:
				print("max spawned")
				
			var timer : float = randf_range(3,10)
			enemy_cnt = get_tree().get_nodes_in_group("Enemy").size()
			#print("enemy spawn :", enemy_cnt)
			spawn_timer.start(timer)

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

func toggle_active(spawn):
	if spawn==spawn_type:
		active = !active

func spawn_update(enemy_spawn, add : bool):
	
	#if enemy_spawn is Dictionary:
		#for enemy_type in enemy_spawn.keys():
			#if not enemy_type.is_in_group("Enemy"):
				#push_error("ERROR Adding non enemy "+enemy_type.name+" to enemy spawn")
				#return
	#elif enemy_spawn is PackedScene:
		#if not enemy_spawn.is_in_group("Enemy"):
			#push_error("ERROR Adding non enemy "+enemy_spawn.name+" to enemy spawn")
			#return
	
	if add:
		if enemy_spawn is Dictionary:
			for enemy_type in enemy_spawn.keys():
				enemy.append(enemy_spawn[enemy_type])
		elif enemy_spawn is PackedScene:
			enemy.append(enemy_spawn)
		
		spawn_size = enemy.size()
	else:
		if enemy_spawn is Dictionary:
			for enemy_type in enemy_spawn.keys():
				enemy.erase(enemy_spawn[enemy_type])
		elif enemy_spawn is PackedScene:
			enemy.erase(enemy_spawn)
		
		spawn_size = enemy.size()
		
	#print(enemy.size())

func spawn_timer_update(value : float) -> void:
	spawn_timer.wait_time=value

func heat_increased(value : int) -> void:
	max_enemy+=1
	spawn_timer.wait_time-=0.5
	
	
func reset_heat() -> void:
	max_enemy=2
	spawn_timer.wait_time=5


func _on_area_2d_area_entered(area: Area2D) -> void:
	area_colliding=true
	print("no spawn")


func _on_area_2d_area_exited(area: Area2D) -> void:
	area_colliding=false
	print("spawn")


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	no_spawn_entered=true


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	no_spawn_entered=false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("WorldStatic"):
		body_colliding=true
		

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("WorldStatic"):
		body_colliding=false
