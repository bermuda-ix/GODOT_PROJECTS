extends Node2D

@export var spawn_connected : Array[SpawnPoint] 
@export var spawn_type : String = "enemy"
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

func _ready() -> void:
	collision_shape_2d.disabled=false



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("spawn_active")
		spawn_connected[0].activate(spawn_type)
		spawn_connected[1].activate(spawn_type)
