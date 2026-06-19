class_name DodgeManager

extends Node

@export var actor : Node2D
@export var state_machine : LimboHSM
@export var bt_player : BTPlayer

func dodge():
	state_machine.dispatch(&"dodge")
