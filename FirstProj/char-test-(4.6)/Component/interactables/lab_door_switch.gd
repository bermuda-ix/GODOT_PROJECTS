extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var doors_connected : Array[Node2D]
@export var key_required : bool = false
@export var key_type : String
@export var flag_connect : LocalFlag

func _ready():
	animated_sprite_2d.frame=0
	

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if key_required:
			if InventoryDict.player_inventory.has(key_type):
				animated_sprite_2d.frame=1
				#door_connect.open()
				for _door in doors_connected:
					if _door.has_method("unlock"):
						_door.unlock()
					elif _door.has_method("open"):
						_door.open()
					else:
						pass
			else:
				body.talk("I need a keycard")
		else:
			animated_sprite_2d.frame=1
			#door_connect.open()
			for _door in doors_connected:
				if _door.has_method("unlock"):
					_door.unlock()
				elif _door.has_method("open"):
					_door.open()
				else:
					pass
			if flag_connect != null:
				flag_connect.flag_triggered.emit()
