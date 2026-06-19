class_name ObjectiveHandler extends Node

#Level Objective data
@export_category("Level Objective Data")
@export var objective_name : String
@export var objective_lvl : String

func update_objective(_update_type : String = "reduce", _value : String = "1"):
	match _update_type:
		"reduce":
			var _ammount = ObjectivesByLevel.get_objective_amount(objective_lvl, objective_name)
			_ammount -= int(_value)
			ObjectivesByLevel.update_objective(objective_lvl, objective_name, _ammount)
		"add":
			var _ammount = ObjectivesByLevel.get_objective_amount(objective_lvl, objective_name)
			_ammount += int(_value)
			ObjectivesByLevel.update_objective(objective_lvl, objective_name, _ammount)
		"alter":
			ObjectivesByLevel.update_objective(objective_lvl, objective_name, _value)
