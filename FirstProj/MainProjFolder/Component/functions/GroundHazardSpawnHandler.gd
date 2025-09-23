class_name GroundHazardSpawnHandler extends Node2D

@export var hazard : PackedScene : set = set_hazard
@export var actor : Node2D
@export var player_trigger : bool = false
@onready var timer: Timer = $Timer

func spawn_hazard():
	var hazard_inst = hazard.instantiate()
	hazard_inst.global_position=global_position
	get_tree().current_scene.add_child(hazard_inst)

func set_hazard(value) -> void:
	hazard=value
	


func _on_player_detect_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if player_trigger:
			spawn_hazard()
