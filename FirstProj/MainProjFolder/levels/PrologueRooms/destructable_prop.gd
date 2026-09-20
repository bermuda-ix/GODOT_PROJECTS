extends AnimatedSprite2D

@export var connected_actor : Node2D = null
@export var platform : CollisionShape2D = null

func _ready() -> void:
	animation="default"
	if connected_actor != null:
		connected_actor.tree_exited.connect(destruct)
	
func destruct() -> void:
	animation="broke"
	if platform!=null:
		platform.set_deferred("disabled", true)
