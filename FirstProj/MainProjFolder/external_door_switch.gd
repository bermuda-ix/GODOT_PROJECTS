extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

#name of door connected to switch
@export var connected_door : String




func _ready():
	animated_sprite_2d.frame=0
	

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		animated_sprite_2d.frame=1
		Events.unlock_door.emit(connected_door)
		#persistent_data_handler.set_value("open")
