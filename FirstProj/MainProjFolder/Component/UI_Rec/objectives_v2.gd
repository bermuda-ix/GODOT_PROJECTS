extends HBoxContainer
@onready var texture_rect: TextureRect = $TextureRect
@onready var rich_text_label: RichTextLabel = $RichTextLabel

@export var objective_texture : Texture2D : set = set_objective_texture
@export var objective_amount : int = 0 : set = set_amount

func set_objective_texture(texture : Texture2D) -> void:
	objective_texture=texture
	
func set_amount(_amount : int) -> void:
	objective_amount=_amount
	
func update_objective_ui() -> void:
	rich_text_label.text="x"+str(objective_amount)
	texture_rect.texture=objective_texture
