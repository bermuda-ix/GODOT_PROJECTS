class_name objective_ui extends Control

@onready var level_objective : PackedScene = preload("res://Component/UI_Rec/objective.tscn")
@onready var grid_container: objective_ui = $"."
@export var objective_resources : Array[objective_item]

func _ready() -> void:
	#TESTING TO BE REMOVED#
	pass

func add_objective(name : String, value : int) -> void:
	var new_level_objective = level_objective.instantiate()
	var item_res : int
	for i in objective_resources.size():
		if objective_resources[i].name == name:
			item_res=i
			break
		else:
			push_error("ITEM RESOURCE MISSING: Please check if item resource is in items_resources array in inventory_ui.gd")
	new_level_objective.name=name
	grid_container.add_child(new_level_objective)
	new_level_objective.set_amount(value)
	new_level_objective.set_objective_texture(objective_resources[item_res].texture)
	print("adding new inv item: ", new_level_objective.name)
	new_level_objective.update_objective_ui()
	
func remove_objective(name : String) -> void:
	print("remove new inv item: ", name)
	var objective_remove : inv_item = grid_container.find_child(name)
	grid_container.remove_child(objective_remove)
	objective_remove.queue_free()
	
func update_objective(name : String, value : int) -> void:
	var objective_update : Objective = grid_container.find_child(name)
	print(objective_update.name, " is updating")
	objective_update.amount_text.text=str(value)

func _init_objectives_list(_objectives_list : Dictionary) -> void:
	for _objective in _objectives_list:
		add_objective(_objective, _objectives_list[_objective])
