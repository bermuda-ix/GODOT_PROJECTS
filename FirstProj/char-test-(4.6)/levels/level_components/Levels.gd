class_name Levels extends Node

const MAIN_MENU = "res://LVL_Transitions/main_menu.tscn"
const LEVEL_SELECT = "res://LVL_Transitions/lvlselect.tscn"
const HIGHSCORE_ENTRY = "res://LVL_Transitions/highscore_entry.tscn"
const HIGHSCORE_LIST = "res://LVL_Transitions/highscore_list.tscn"

@onready var levels : Dictionary = {
		"GuantletLvl" : "uid://djj0ggyoi07b2",
		"PrologueLvl" : "uid://bwy4dfs27ji8h",
		"prologue_room_1" : "uid://b2ll7yf0xbexn",
		"prologue_room_2" : "uid://bqrvktluv2fur",
		"prologue_room_3" : "uid://y6x600dn2kkk",
		"PrologueHallway1" : "uid://cty2do01q2lg5",
		"PrologueTestlab1" : "uid://dm38jv1jmwb8o",
		"PrologueGarage1" : "uid://cg3hpqv70xol4",
		"PrologueGarage2" : "uid://c8il70paf1pfv",
		"PrologueGarage3" : "uid://cpax3imqk1mix"
		
	}




#Unique rooms in levels
@onready var prologue_unique_levels : Dictionary = {
		"PrologueLvl" : "uid://bwy4dfs27ji8h",
		"PrologueHallway1" : "uid://cty2do01q2lg5",
		"PrologueTestlab1" : "uid://dm38jv1jmwb8o",
		"PrologueGarage1" : "uid://cg3hpqv70xol4",
		"PrologueGarage2" : "uid://c8il70paf1pfv",
		"PrologueGarage3" : "uid://cpax3imqk1mix"
	}
#Cutscenes PackedScenes
@onready var adv_cutscenes : Dictionary ={
	"IntroCutscene" : "uid://cimg1u7dq8qci"
}



@onready var guantlet_lvls : Dictionary = {
		"GuantletLvl" : "uid://djj0ggyoi07b2"
	}
	
#####################################################
###TODO: Function to Unload Rooms not in map      ###
###		 Save persistant data from unloaded rooms ###
###		 Reload persistant data on flag           ###
#####################################################

#Connected duplicated rooms
@onready var level_maps : Dictionary = {
	
	}
