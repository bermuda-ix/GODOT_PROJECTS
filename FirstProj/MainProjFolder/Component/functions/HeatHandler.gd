class_name HeatHandler

extends Node

var lvl : Node2D
var ui_level : Control

@export_category("Spawn Variables")
@export var heat_spawn_rate : Array[float] = [10,9,8,7,6,5,4,3]
@export var heat_spawn_max : Array[int] = [1,2,3,4,5,6,7,8]
@export var max_heat_level := 3
@export var current_heat := 0
@export var region_name := "ADV_FLASHBACK"

func _ready() -> void:
	lvl=get_tree().get_first_node_in_group("GameLevel")
	ui_level=get_tree().get_first_node_in_group("GameUI")
	Events.increase_heat_lvl.connect(update_spawn)
	#Load current and max heat on room load
	Events.retrieve_heat_stats.connect(load_heat)

func heat_lvl_spawn():
	if lvl.spawn_points.is_empty():
		pass
	else:
		for i in lvl.spawn_points.size():
			lvl.spawn_points[i].spawn_timer_update(heat_spawn_rate[ui_level.heat_lvl])
			lvl.spawn_points[i].max_enemy=heat_spawn_max[ui_level.heat_lvl]
	
	
	#match ui_level.heat_fill:
		#0:
			#pass
		#1:
			#pass
		#2:
			#pass
		#3:
			#pass
		#4:
			#pass
		#5:
			#pass
		#6:
			#pass
		#7:
			#pass
		#8:
			#pass
		#9:
			#pass
		#10:
			#pass

func update_spawn():
	var _spawn_points := get_tree().get_nodes_in_group("SpawnPoint")
	for i in range(_spawn_points.size(), 0, -1):
		_spawn_points[i].max_enemy=heat_spawn_max[current_heat]
		_spawn_points[i].spawn_timer_update(heat_spawn_rate[current_heat])

func reset_spawn():
	current_heat=0
	var _spawn_points := get_tree().get_nodes_in_group("SpawnPoint")
	for i in range(_spawn_points.size(), 0, -1):
		_spawn_points[i].max_enemy=heat_spawn_max[0]
		_spawn_points[i].spawn_timer_update(heat_spawn_rate[0])

func increase_heat(value : int) -> void:
	current_heat+=value
	GlobalSaveData.heat_stats[region_name]["current_heat_level"]=current_heat
	update_spawn()

func load_heat(_region : String = "ADV_FLASHBACK") -> void:
	if _region == region_name:
		current_heat=GlobalSaveData.heat_stats[region_name]["current_heat_level"]
		update_spawn()

func set_max_heat(_value : int) -> void:
	max_heat_level=_value
