class_name objectives_by_level extends Node

@onready var prologue_init_objectives : Dictionary = {"truck" : "5",
"wreck shit": "Make it loud"}
@onready var guanlet_init_objectives : Dictionary = { }
@onready var objectives_total : Dictionary = { }


@onready var objective_resorces : Dictionary = {
	"truck" : {
		"TEXTURE" : "uid://bwdyhehw5j8uj",
		"TYPE" : "multi"
		},
	"wreck shit" :{
		"TEXTURE" : "uid://bwdyhehw5j8uj",
		"TYPE" : "single"
	}
}

func _ready() -> void:
	objectives_total = {"Prologue" : prologue_init_objectives}

func update_objective(obj_level : String, obj_name : String, value : String) -> void:
	objectives_total[obj_level][obj_name]=value

func remove_objective(obj_level : String, obj_name : String) -> void:
	if objectives_total[obj_level].has(obj_name):
		objectives_total[obj_level].erase(obj_name)
	else:
		pass
		
func get_objective_amount(obj_level : String, obj_name : String) -> int:
	return int(objectives_total[obj_level][obj_name])
