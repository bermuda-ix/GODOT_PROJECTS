extends Sprite2D

@export var connected_elevator : elevator
@export var floor : int
@onready var player_entered : bool = false

func _process(delta: float) -> void:
	if not player_entered:
		return
	else:
		if Input.is_action_just_pressed("Interact"):
			call_elevator()


func call_elevator() -> void:
	if floor == connected_elevator.get_floor_number():
		return
	else:
		connected_elevator.choose_floor(floor)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_entered=true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_entered=false
