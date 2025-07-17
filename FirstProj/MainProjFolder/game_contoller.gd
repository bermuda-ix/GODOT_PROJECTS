class_name GameController extends Node

@export var world_2d : Node2D
@export var gui : Control

@onready var player : PlayerEntity

var current_2d_scene
var current_gui_scene

#@onready var prologue_lvl: adv_level = $World2D/PrologueLvl

func _ready() -> void:
	Global.game_controller = self
	current_2d_scene=$World2D/PrologueLVLRooms/PrologueLvl

func change_2d_scene(new_scene: String, delete: bool = true, keep_running: bool = false, starting_pos: int = 0) -> void:
	if current_2d_scene != null:
		if delete:
			current_2d_scene.queue_free() #Deletes node entirely
		elif keep_running:
			current_2d_scene.visible = false #Keep in mem and running
		else:
			world_2d.remove_child(current_2d_scene) #Keep in mem, not running
	
	var new = load(new_scene).instantiate()
	new.set_starting_pos()
	player.global_position=new.starting_pos[starting_pos].global_position
	world_2d.add_child(new)
	current_2d_scene=new
	
	
