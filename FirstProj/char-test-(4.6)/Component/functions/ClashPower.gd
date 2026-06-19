class_name ClashPower

extends Node

@export var clash_max : int = 5
@onready var clash_power : int = clampi(0, 0, clash_max)

@export var health : Health
@export var stagger : Stagger

signal clashed
signal aura_change(value: int)
signal aura_reset

func _ready() -> void:
	clashed.connect(increase_clash)
	
func increase_clash() -> void:
	if clash_power>=clash_max:
		return
	clash_power+=1
	aura_change.emit(clash_power)

func decrease_clash() -> void:
	if clash_power<=0:
		return
	clash_power-=1
	aura_change.emit(clash_power)

func reset_clash() -> void:
	clash_power=0
	aura_reset.emit()
