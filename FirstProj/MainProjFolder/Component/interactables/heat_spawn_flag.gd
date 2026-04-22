extends Node2D

@export var spawn_connected : Array[SpawnPoint] 
@export var spawn_type : String = "enemy"
@export var spawn_toggle_mode := true
@export var max_heat := 5
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

signal set_max_heat
signal toggle_spawn(bool, String)

func _ready() -> void:
	collision_shape_2d.disabled=false



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print_debug("spawn_active")
		toggle_spawn.emit(spawn_toggle_mode, spawn_type)
		set_max_heat.emit(max_heat)
		
		#if spawn_activate:
			#spawn_connected[0].activate(spawn_type)
			#spawn_connected[1].activate(spawn_type)
			#set_max_heat.emit(max_heat)
			#toggle_spawn.emit(true)
		#else:
			#spawn_connected[0].deactivate(spawn_type)
			#spawn_connected[0].deactivate(spawn_type)
