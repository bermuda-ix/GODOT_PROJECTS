extends HBoxContainer


@export var ammo_type : Texture2D = preload("uid://bkgslht0ude5a")
@export var max_ammo : int = 8
@export var current_ammo : int = 8
@export var seperation : int = -16


func _ready() -> void:
	Events.set_ammo_type.connect(set_ammo_gui)
	Events.remove_ammo.connect(remove_ammo)
	Events.reload_ammo.connect(reloading_ammo)
	set_ammo_gui()
	
#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("DEBUG_KEY"):
		#remove_ammo()

func set_ammo_gui() -> void:
	grow_horizontal=Control.GROW_DIRECTION_END
	add_theme_constant_override("separation", seperation)
	for i in range(max_ammo, 0, -1):
		var ammo_texture_rect : TextureRect = TextureRect.new()
		ammo_texture_rect.texture=ammo_type
		ammo_texture_rect.expand_mode=TextureRect.EXPAND_FIT_WIDTH
		ammo_texture_rect.texture=ammo_type
		#var _ammo = ammo_texture_rect.instantiate()
		add_child(ammo_texture_rect)

func remove_ammo() -> void:
	if current_ammo<=0:
		return
	else:
		var _cur_ammo := get_children()
		var _last_ammo = _cur_ammo.back()
		remove_child(_last_ammo)
		current_ammo-=1
	
func reloading_ammo(_ammo : int = 1) -> void:
	if current_ammo>=max_ammo:
		return
	else:
		if _ammo==1:
			var ammo_texture_rect : TextureRect = TextureRect.new()
			ammo_texture_rect.texture=ammo_type
			ammo_texture_rect.expand_mode=TextureRect.EXPAND_FIT_WIDTH
			ammo_texture_rect.texture=ammo_type
			#var _ammo = ammo_texture_rect.instantiate()
			add_child(ammo_texture_rect)
			current_ammo+=1
		else:
			for i in range(_ammo, 0, -1):
				var ammo_texture_rect : TextureRect = TextureRect.new()
				ammo_texture_rect.texture=ammo_type
				ammo_texture_rect.expand_mode=TextureRect.EXPAND_FIT_WIDTH
				ammo_texture_rect.texture=ammo_type
				#var _ammo = ammo_texture_rect.instantiate()
				add_child(ammo_texture_rect)
				current_ammo+=1

func set_ammo_type(_texture : Texture2D) -> void:
	ammo_type=_texture
