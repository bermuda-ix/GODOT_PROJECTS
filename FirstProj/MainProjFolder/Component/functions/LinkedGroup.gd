class_name LinkedGroup

extends Node

@export var actor : Array[Node2D]

func _ready() -> void:
	for i in actor.size():
		print_debug(actor[i].name, "linked")
