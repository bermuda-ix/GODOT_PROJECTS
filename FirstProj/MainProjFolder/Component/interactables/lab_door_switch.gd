extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var door_connect : Node2D
@export var key_required : bool = false
@export var key_type : String

func _ready():
	animated_sprite_2d.frame=0
	

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if key_required:
			if InventoryDict.player_inventory.has(key_type):
				animated_sprite_2d.frame=1
				door_connect.open()
			else:
				body.talk("I need a keycard")
		else:
			animated_sprite_2d.frame=1
			door_connect.open()
