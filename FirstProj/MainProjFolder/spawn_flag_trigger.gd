extends Node2D

@export var spawn_connected : SpawnPoint
@export var spawn_type : String = "enemy"
@onready var collision_shape_2d: CollisionShape2D = $SpawnFlagTrigger/CollisionShape2D

func _ready() -> void:
	collision_shape_2d.disabled=false



func _on_spawn_flag_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("spawn_activate")
		collision_shape_2d.disabled=true
		spawn_connected.activate(spawn_type)
