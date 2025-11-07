class_name Objective extends Control

@onready var objective_texture_rect: TextureRect = $ObjectiveType/TextureRect
@onready var objective_amount_text: Label = $ObjectiveAmount/Label

@export var objective_texture : Texture2D : set = set_objective_texture
@export var objective_amount : int = 0 : set = set_amount


func set_objective_texture(texture : Texture2D) -> void:
	pass
	
func set_amount(_amount : int) -> void:
	pass
	
func update_objective_ui() -> void:
	objective_amount_text.text=str(objective_amount)
	objective_texture_rect.texture=objective_texture
