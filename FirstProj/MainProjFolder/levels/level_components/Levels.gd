class_name Levels extends Node

@onready var levels : Dictionary = {
		"prologue" : "res://levels/PrologueRooms/prologue_lvl.tscn",
		"prologue_room_1" : "res://levels/PrologueRooms/prologue_room_one.tscn",
		"prologue_room_2" : "res://levels/PrologueRooms/prologue_room_2.tscn",
		"prologue_room_3" : "res://levels/PrologueRooms/prologue_room_tres.tscn",
		"PrologueHallway1" : "res://levels/PrologueRooms/prologue_hallway_1.tscn",
		"PrologueTestlab1" : "res://levels/PrologueRooms/prologue_testlab_1.tscn"
		
	}

#Unique rooms in levels
@onready var prologue_unique_levels : Dictionary = {
		"prologue" : "res://levels/PrologueRooms/prologue_lvl.tscn",
		"PrologueHallway1" : "res://levels/PrologueRooms/prologue_hallway_1.tscn",
		"PrologueTestlab1" : "res://levels/PrologueRooms/prologue_testlab_1.tscn"
	}

#Connected duplicated rooms
@onready var proloque_level_maps : Dictionary = {
	
	}
