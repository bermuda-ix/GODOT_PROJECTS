class_name HeatHandler

extends Node

@export var lvl : Node2D
@export var ui_level : Control

@export_category("Spawn Variables")
@export var heat_spawn_rate : Array[float] = [10,9,8,7,6,5,4,3,2,1]
@export var heat_spawn_max : Array[int] = [1,2,3,4,5,6,7,8,9,10]



func heat_lvl_spawn():
	if lvl.spawn_points.is_empty():
		pass
	else:
		for i in lvl.spawn_points.size():
			lvl.spawn_points[i].spawn_timer_update(heat_spawn_rate[ui_level.heat_fill])
			lvl.spawn_points[i].max_enemy=heat_spawn_max[ui_level.heat_fill]
	
	
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
