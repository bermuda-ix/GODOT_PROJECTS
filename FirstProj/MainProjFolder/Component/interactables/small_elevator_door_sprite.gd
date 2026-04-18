extends Node2D

@export var closed : bool = true
@export var floor : int = 0
@export var connected_elevator : elevator_front
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var floor_collision: CollisionPolygon2D = $floor_collision/floor_collision


func _ready() -> void:
	if closed:
		animation_player.play("close")
		floor_collision.set_deferred("disabled", false)
		z_index=0
	else:
		floor_collision.set_deferred("disabled", false)
		z_index=2
		animation_player.play("open")
	
	connected_elevator.open_door.connect(open)
	connected_elevator.close_door.connect(close)
		
		
func open() -> void:
	if connected_elevator.get_floor_number()!=floor:
		return
	else:
		if closed:
			floor_collision.set_deferred("disabled", false)
			z_index=0
			animation_player.play("open")
			closed=false
	
func close() -> void:
	if not closed:
		floor_collision.set_deferred("disabled", false)
		z_index=2
		animation_player.play("close")
		closed=true



func _on_animation_player_animation_started(anim_name: StringName) -> void:
	print_debug(anim_name)
