class_name GameController extends Node

@onready var world_2d: Node2D = $World2D

@export var gui : Control

@onready var player: PlayerEntity = $World2D/PrologueLvl/Player
@onready var pause_menu: ColorRect = $GUI/CanvasLayer/PauseMenu
@onready var levels: Levels = $Levels
@onready var queued_rooms : Array[String] = []
@onready var loaded_rooms : Array[PackedScene] = []
@onready var current_room : int = 0


var current_2d_scene
var prev_2d_scene
var current_gui_scene

#@onready var prologue_lvl: adv_level = $World2D/PrologueLvl

func _ready() -> void:	
	Global.game_controller = self
	current_2d_scene=$World2D/PrologueLvl
	prev_2d_scene=current_2d_scene
	#var test_scene="res://levels/prologue_lvl.tscn"
	#change_2d_scene(test_scene, true, false, 0)
	current_2d_scene.player=player
	Events.pause.connect(show_pause)
	Events.unpause.connect(unpause)
	load_levels(LevelsList.prologue_levels)

	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		show_pause()
	
func show_pause():
	pause_menu.show()
	get_tree().paused = true
	
func unpause():
	pause_menu.hide()
	get_tree().paused = false
	
func load_levels(dict : Dictionary) -> void:
	for key in dict.keys():
		queued_rooms.append(dict[key])
	loaded_rooms.append(load(queued_rooms[0]))
	loaded_rooms.append(load(queued_rooms[1]))
	loaded_rooms.append(load(queued_rooms[2]))
	loaded_rooms.append(load(queued_rooms[2]))
	loaded_rooms.append(load(queued_rooms[3]))
	loaded_rooms.append(load(queued_rooms[2]))
	loaded_rooms.append(load(queued_rooms[3]))
	


func change_2d_scene(new_scene: String, \
	delete: bool = true, \
	keep_running: bool = false, \
	starting_pos: int = 0, \
	_transition_in : String="fade_to_black", \
	_transition_out : String="fade_from_black") -> void:
	
	player.reparent(world_2d)
	await LevelTransition.transition_in(_transition_in)
	if current_2d_scene != null:
		if delete:
			current_2d_scene.queue_free() #Deletes node entirely
		elif keep_running:
			current_2d_scene.visible = false #Keep in mem and running
		else:
			world_2d.remove_child(current_2d_scene) #Keep in mem, not running
	
	
	
	if new_scene==prev_2d_scene.get_scene_file_path():
		world_2d.add_child(prev_2d_scene)
		player.reparent(prev_2d_scene)
		prev_2d_scene.player.global_position=prev_2d_scene.starting_pos[starting_pos].global_position
		LevelTransition.transition_out(_transition_out)
		var temp = prev_2d_scene
		prev_2d_scene=current_2d_scene
		current_2d_scene=temp
	else:
		var new = load(new_scene).instantiate()
		world_2d.add_child(new)
		player.reparent(new)
		new.player.global_position=new.starting_pos[starting_pos].global_position
		LevelTransition.transition_out(_transition_out)
		prev_2d_scene=current_2d_scene
		current_2d_scene=new
	
	
