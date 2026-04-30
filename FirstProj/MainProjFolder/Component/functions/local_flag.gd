class_name LocalFlag extends Node2D

@export var cutscene_name : String
@export var flag_active : bool = false
@export var dialogue_only : bool = true
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
signal play_cutscene(_cutscene_name : String)


func _ready() -> void:
	collision_shape_2d.disabled=false

func flag_toggle():
	flag_active!=flag_active

func flag_reset():
	collision_shape_2d.call_deferred("set_disabled", false)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and flag_active:
		print_debug("local flag activate")
		#collision_shape_2d.disabled=true
		collision_shape_2d.call_deferred("set_disabled", true)
		play_cutscene.emit(cutscene_name)
