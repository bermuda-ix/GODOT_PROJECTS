class_name objectives_by_level extends Node

@onready var prologue_init_objectives : Dictionary = {"bluemech" : 5, "redmech" : 3, "greenmech" : 5}
@onready var objectives_total : Dictionary = { }

func _ready() -> void:
	objectives_total = {"Prologue" : prologue_init_objectives}

func update_objective(obj_level : String, obj_name : String, amount : int) -> void:
	objectives_total[obj_level][obj_name]=amount

func remove_objective(obj_level : String, obj_name : String) -> void:
	if objectives_total[obj_level].has(obj_name):
		objectives_total[obj_level].erase(obj_name)
	else:
		pass
		
func get_objective_amount(obj_level : String, obj_name : String) -> int:
	return objectives_total[obj_level][obj_name]
