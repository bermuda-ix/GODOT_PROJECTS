extends Node2D

@export var closed : bool = true
@export var floor : int = 0
@export var connected_elevator : elevator_front
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var floor_collision: CollisionPolygon2D = $floor_collision/floor_collision

@onready var player_entered : bool = false
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D


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
	Events.call_elevator.connect(call_elevator)
		
	if connected_elevator.get_floor_number()==floor:
		collision_shape_2d.set_deferred("disabled",true)
	else:
		collision_shape_2d.set_deferred("disabled",false)
		
func open() -> void:
	if connected_elevator.get_floor_number()!=floor:
		return
	else:
		if closed:
			floor_collision.set_deferred("disabled", false)
			z_index=0
			animation_player.play("open")
			closed=false
			if connected_elevator.get_floor_number()==floor:
				collision_shape_2d.set_deferred("disabled",true)
			else:
				collision_shape_2d.set_deferred("disabled",false)
	
func close() -> void:
	if not closed:
		floor_collision.set_deferred("disabled", false)
		z_index=2
		animation_player.play("close")
		closed=true

func call_elevator() -> void:
	if not player_entered:
		return
	else:
		var _elevator_floor = connected_elevator.get_floor_number()
		if floor == _elevator_floor or not connected_elevator.stopped:
			return
		else:
			connected_elevator.choose_floor(floor)
		

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	print_debug(anim_name)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_entered=true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_entered=false
