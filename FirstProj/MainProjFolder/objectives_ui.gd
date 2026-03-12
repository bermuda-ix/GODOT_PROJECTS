class_name objective_ui extends GridContainer

@onready var level_objective : PackedScene = preload("uid://0nnvnrxj3c5x")
@onready var level_objective_single : PackedScene = preload("uid://cob0msx6dar0l")
@onready var grid_container: objective_ui = $"."
@onready var objectives: VBoxContainer = $Objectives


@export var objective_resources : Array[objective_item]

func _ready() -> void:
	#TESTING TO BE REMOVED#
	pass


func add_objective(_name : String, _value : String = "objective instruction", _type : String = "multi") -> void:
	var new_level_objective
	#var item_res : int
	#for i in objective_resources.size():
		#if objective_resources[i].name == name:
			#item_res=i
			#break
		#else:
			#push_error("ITEM RESOURCE MISSING: Please check if item resource is in items_resources array in inventory_ui.gd")
	
	if _type == "multi":
		new_level_objective = level_objective.instantiate()
		new_level_objective.set_amount(int(_value))
	else:
		new_level_objective = level_objective_single.instantiate()
		new_level_objective.set_text(_value)
	
	
	new_level_objective.name=_name
	var obj_texture=load(ObjectivesByLevel.objective_resorces[_name]["TEXTURE"])
	new_level_objective.set_objective_texture(obj_texture)
	print_debug("adding new inv item: ", new_level_objective.name)
	objectives.add_child(new_level_objective)
	#objectives.call_deferred("add_child",new_level_objective)
	#await new_level_objective.call_deferred_thread_group("tree_entered")
	#while true:
		#if new_level_objective.texture_rect!=null:
			#break
	new_level_objective.update_objective_ui()


func remove_objective(name : String) -> void:
	print_debug("remove new inv item: ", name)
	var objective_remove : inv_item = objectives.find_child(name)
	objectives.call_deferred("remove_child", objective_remove)
	objective_remove.queue_free()
	
func update_objective(name : String, value : int = 1, type : String = "multi") -> void:
	var objective_update : Objective = objectives.find_child(name)
	print_debug(objective_update.name, " is updating")
	objective_update.amount_text.text=str(value)

func _init_objectives_list(_objectives_list : Dictionary) -> void:
	for _objective in _objectives_list:
		add_objective(_objective, _objectives_list[_objective], ObjectivesByLevel.objective_resorces[_objective]["TYPE"])
