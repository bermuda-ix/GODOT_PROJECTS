class_name GroupEnemyManager

extends Node

@export var actor : Node2D

#Grouping enemies
#@onready var linked_enemies : Array[Node2D]
#@export var group_link_control : EnemyGroup
#@onready var group_link_order : int
@onready var leader : bool = false : set = set_leader, get = get_leader
@onready var even_order : bool = false : set = set_even_order, get = get_even_order


#GROUP Functions
func set_leader(value: int) -> void:
	if value==0:
		leader=true
		print("leader found")
	else:
		leader=false

func get_leader() -> bool:
	return leader

func set_even_order(value: int):
	if value==0 or value % 2 == 0:
		even_order=true
		print("I'm even")
	else:
		even_order=false
		print("I'm odd")

func get_even_order() -> bool:
	return even_order
