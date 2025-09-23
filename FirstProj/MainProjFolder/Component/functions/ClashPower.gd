class_name ClashPower

extends Node

@export var clash_max : int = 3
@onready var clash_power : int = clampi(1, 1, clash_max)

@export var health : Health
@export var stagger : Stagger

signal clashed

func _ready() -> void:
	clashed.connect(increase_clash)
	
func increase_clash() -> void:
	clash_power+=1

func reset_clash() -> void:
	clash_power=1
