extends HBoxContainer
@onready var texture_rect: TextureRect = $TextureRect
@onready var rich_text_label: RichTextLabel = $RichTextLabel

@export var objective_texture : Texture2D : set = set_objective_texture
@export var objective_text : String : set = set_text

func set_objective_texture(texture : Texture2D) -> void:
	objective_texture=texture
	
func set_text(_objective : String) -> void:
	objective_text=_objective
	
func update_objective_ui() -> void:
	rich_text_label.text=str(objective_text)
	texture_rect.texture=objective_texture
