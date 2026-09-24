class_name objectives_by_level extends Node

@onready var prologue_init_objectives : Dictionary = {"Generator" : "Destroy",
"Find this": "□□□□□□□□"}
@onready var guanlet_init_objectives : Dictionary = { }
@onready var objectives_total : Dictionary = { }


@onready var objective_resorces : Dictionary = {
	"Generator" : {
		"TEXTURE" : "uid://cdwyn7p3rgiuq",
		"TYPE" : "Single"
		},
	"Find this" :{
		"TEXTURE" : "uid://cshwi53lwaqph",
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
