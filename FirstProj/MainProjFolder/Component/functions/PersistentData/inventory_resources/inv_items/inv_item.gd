class_name inv_item extends Control

@onready var inv_item_texture_rect: TextureRect = $InvItemTexture/TextureRect
@onready var amount_text: TextEdit = $AmountText/TextEdit

@export var inv_item_texture : Texture2D : set = set_item_texture
@export var amount : int = 0 : set = set_amount




func set_item_texture(value : Texture2D) -> void:
	inv_item_texture = value
	
	
func set_amount(value : int) -> void:
	amount = value
	
func update_ui() -> void:
	amount_text.text=str(amount)
	inv_item_texture_rect.texture=inv_item_texture
#func _process(delta: float) -> void:
	#inv_item_texture_rect.texture=inv_item_texture
	#amount_text.test= "x"+str(amount)
