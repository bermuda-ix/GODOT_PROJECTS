extends Node2D

@onready var animation_tree: AnimationPlayer = $AnimationTree

func _ready() -> void:
	Events.open_door.connect(open)

func open():
	animation_tree.play("open")
	await animation_tree.animation_finished
	Events.door_opened.emit()
	
