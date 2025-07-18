class_name GameController extends Node

@onready var world_2d: Node2D = $World2D

@export var gui : Control

@onready var player: PlayerEntity = $World2D/PrologueLvl/Player

var current_2d_scene
var current_gui_scene

#@onready var prologue_lvl: adv_level = $World2D/PrologueLvl

func _ready() -> void:	
	Global.game_controller = self
	current_2d_scene=$World2D/PrologueLvl
	#var test_scene="res://levels/prologue_lvl.tscn"
	#change_2d_scene(test_scene, true, false, 0)
	current_2d_scene.player=player


func change_2d_scene(new_scene: String, delete: bool = true, keep_running: bool = false, starting_pos: int = 0) -> void:
	
	player.reparent(world_2d)
	await LevelTransition.fade_to_black()
	if current_2d_scene != null:
		if delete:
			current_2d_scene.queue_free() #Deletes node entirely
		elif keep_running:
			current_2d_scene.visible = false #Keep in mem and running
		else:
			world_2d.remove_child(current_2d_scene) #Keep in mem, not running
	
	
	var new = load(new_scene).instantiate()
	world_2d.add_child(new)
	player.reparent(new)
	new.player.global_position=new.starting_pos[starting_pos].global_position
	LevelTransition.fade_from_black()
	current_2d_scene=new
	
	
