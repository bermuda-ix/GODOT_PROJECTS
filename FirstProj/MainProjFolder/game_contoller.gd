class_name GameController extends Node

@onready var world_2d: Node2D = $World2D

@export var gui : Control

@onready var player: PlayerEntity = $World2D/Player
@onready var pause_menu: Control = $GUI/CanvasLayer/PauseMenuv2
@onready var gameui: Control = $GUI/CanvasLayer/GAMEUI
@onready var ui_level: Control = $GUI/CanvasLayer/GAMEUI/UI_Level
@onready var objectives_ui: objective_ui = $GUI/CanvasLayer/PauseMenuv2/TextureRect/MainPause/ObjectivesUI
@onready var level_UI: CanvasLayer = $GUI/CanvasLayer



@onready var levels: Levels = $Levels
@onready var queued_rooms : Array[String] = []
@onready var loaded_rooms : Array[Node] = []
@onready var loaded_rooms_map : Dictionary
@onready var current_room : int = 0
@onready var return_room : String = ""

var current_2d_scene
var prev_2d_scene
var current_gui_scene
@onready var prev_gui_scene = "NONE"

#@onready var prologue_lvl: adv_level = $World2D/PrologueLvl

func _ready() -> void:	
	Global.game_controller = self
	Events.load_level_map.connect(load_levels)
	Events.load_first_level.connect(load_first_room)
	Events.toggle_game_ui.connect(toggle_game_ui)
	Events.load_objectives.connect(_init_objectives)
	Events.toggle_level_processing.connect(toggle_world2d_process)
	Events.load_menu_scene.connect(change_gui_scene)
	
	Events.pause.connect(show_pause)
	Events.unpause.connect(unpause)
	
	#Disables game UI and level process when first starting
	toggle_game_ui(false)
	toggle_world2d_process(false)
	toggle_player(false)
	
	#test_start()
	change_gui_scene(LevelList.MAIN_MENU)
	
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		show_pause()

#For force starting levels to test
func test_start() -> void:
	load_levels(LevelsList.prologue_unique_levels)
	load_first_room("prologue")
	prev_2d_scene=current_2d_scene
	current_2d_scene.player=player
	load_levels(LevelsList.prologue_level_maps)
	_init_objectives(ObjectivesByLevel.prologue_init_objectives)

func show_pause():
	pause_menu.show()
	gameui.visible=false
	get_tree().paused = true
	
func unpause():
	get_tree().paused = false
	pause_menu.hide()
	gameui.visible=true
	
	
	
#refactor to use global array/map of full levels
func load_levels(dict : Dictionary) -> void:
	for room in dict:
		
		print(room)
		print(dict[room])
		if loaded_rooms_map.has(room) == false:
			loaded_rooms_map[room]=load(dict[room]).instantiate()
		
		#loaded_rooms.append(load(dict[room]).instantiate())
		#i+=1

#Load first scene on game start
func load_first_room (_first_room : String, \
	_transition_in : String="fade_to_black", \
	_transition_out : String="fade_from_black") -> void:
		
	world_2d.add_child(loaded_rooms_map[_first_room])
	player.reparent(loaded_rooms_map[_first_room])
	loaded_rooms_map[_first_room].player.global_position=loaded_rooms_map[_first_room].init_starting_pos.global_position
	LevelTransition.transition_out(_transition_out)
	current_2d_scene=loaded_rooms_map[_first_room]

#Toggle UI vissibility
func toggle_game_ui(value : bool) -> void:
	level_UI.visible = value
#Toggle world2D, the main level processing tree, processing
func toggle_world2d_process(value : bool) -> void:
	world_2d.set_process(value)

#Change scenes
func change_2d_scene (new_scene: String, \
	delete: bool = true, \
	keep_running: bool = false, \
	_starting_pos: int = 1, \
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
	
	if new_scene=="RETURN":
		new_scene=return_room
	
	world_2d.add_child(loaded_rooms_map[new_scene])
	player.reparent(loaded_rooms_map[new_scene])
	
	#Starting position is -1 if scene has no starting position
	if _starting_pos==-1:
		pass
	else:
		print(loaded_rooms_map[new_scene].starting_pos.size(), " ",_starting_pos)
		loaded_rooms_map[new_scene].player.global_position=loaded_rooms_map[new_scene].starting_pos[_starting_pos]
	LevelTransition.transition_out(_transition_out)
	if current_2d_scene != null:
		prev_2d_scene=current_2d_scene
		return_room=prev_2d_scene.name
	current_2d_scene=loaded_rooms_map[new_scene]
	load_levels(LevelsList.prologue_level_maps)

func _init_objectives(dict : Dictionary):
	objectives_ui._init_objectives_list(dict)

#Change GUI Scene
func change_gui_scene (new_scene: String, \
	delete: bool = true, \
	keep_running: bool = false, \
	_transition_in : String="fade_to_black", \
	_transition_out : String="fade_from_black") -> void:
	LevelTransition.transition_in(_transition_in)
	if current_gui_scene != null:
		prev_gui_scene=current_gui_scene
		gui.remove_child(current_gui_scene)
	current_gui_scene=load(new_scene).instantiate()
	gui.add_child(current_gui_scene)
	LevelTransition.transition_out(_transition_out)
	
func remove_gui_scene (delete: bool = true, \
	keep_running: bool = false, \
	_transition_in : String="fade_to_black", \
	_transition_out : String="fade_from_black") -> void:
	await LevelTransition.transition_in(_transition_in)
	gui.remove_child(current_gui_scene)
	
#func change_2d_scene_old(new_scene: int, \
	#delete: bool = true, \
	#keep_running: bool = false, \
	#_starting_pos: int = 0, \
	#_transition_in : String="fade_to_black", \
	#_transition_out : String="fade_from_black") -> void:
	#
	#
	#player.reparent(world_2d)
	#await LevelTransition.transition_in(_transition_in)
	#if current_2d_scene != null:
		#if delete:
			#current_2d_scene.queue_free() #Deletes node entirely
		#elif keep_running:
			#current_2d_scene.visible = false #Keep in mem and running
		#else:
			#world_2d.remove_child(current_2d_scene) #Keep in mem, not running
	#
	#
	#world_2d.add_child(loaded_rooms[new_scene])
	#player.reparent(loaded_rooms[new_scene])
	#loaded_rooms[new_scene].player.global_position=loaded_rooms[new_scene].starting_pos[_starting_pos-1].global_position
	#LevelTransition.transition_out(_transition_out)
	#prev_2d_scene=current_2d_scene
	#current_2d_scene=loaded_rooms[new_scene]
	#
func toggle_player(activate : bool) -> void:
	if activate:
		if world_2d.has_node(player.get_path()):
			pass
		else:
			world_2d.add_child(player)
	else:
		if world_2d.has_node(player.get_path()):
			world_2d.remove_child(player)
		else:
			pass
		

func _on_player_update_health(value : int) -> void:
	ui_level.set_health(value)


func _on_player_update_max_health(value : int) -> void:
	ui_level.set_max_health(value)
