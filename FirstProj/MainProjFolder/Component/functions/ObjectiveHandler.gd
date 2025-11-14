class_name ObjectiveHandler extends Node

#Level Objective data
@export_category("Level Objective Data")
@export var objective_name : String
@export var objective_lvl : String

func update_objective():
	var _ammount = ObjectivesByLevel.get_objective_amount(objective_lvl, objective_name)
	_ammount -= 1
	ObjectivesByLevel.update_objective(objective_lvl, objective_name, _ammount)
