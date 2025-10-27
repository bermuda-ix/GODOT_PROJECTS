class_name GameController extends Node

@onready var world_2d: Node2D = $World2D

@export var gui : Control

@onready var player: PlayerEntity = $World2D/Player
@onready var pause_menu: ColorRect = $GUI/CanvasLayer/PauseMenu
@onready var gameui: Control = $GUI/CanvasLayer/GAMEUI
@onready var ui_level: Control = $GUI/CanvasLayer/GAMEUI/UI_Level


@onready var levels: Levels = $Levels
@onready var queued_rooms : Array[String] = []
@onready var loaded_rooms : Array[Node] = []
@onready var loaded_rooms_map : Dictionary
@onready var current_room : int = 0
@onready var return_room : String = ""

var current_2d_scene
var prev_2d_scene
var current_gui_scene

#@onready var prologue_lvl: adv_level = $World2D/PrologueLvl

func _ready() -> void:	
	Global.game_controller = self
	#current_2d_scene=$World2D/PrologueLvl
	load_levels(LevelsList.prologue_unique_levels)
	for room_loaded in loaded_rooms_map:
		print(room_loaded)
		print(loaded_rooms_map[room_loaded])
	load_first_room()
	prev_2d_scene=current_2d_scene
	#var test_scene="res://levels/prologue_lvl.tscn"
	#change_2d_scene(test_scene, true, false, 0)
	current_2d_scene.player=player
	Events.pause.connect(show_pause)
	Events.unpause.connect(unpause)
	
	#print(LevelsList.proloque_level_maps)
	#for room in LevelsList.proloque_level_maps:
		#
		#print(room)
		#print(LevelsList.proloque_level_maps[room])
	load_levels(LevelsList.proloque_level_maps)
	for room_loaded in loaded_rooms_map:
		print(room_loaded)
		print(loaded_rooms_map[room_loaded])
		
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		show_pause()
	
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

func load_levels_old(dict : Dictionary) -> void:
	for key in dict.keys():
		queued_rooms.append(dict[key])
		
	for room in LevelsList.proloque_level_maps:
		
		print(room)
		print(LevelsList.proloque_level_maps[room])
		#loaded_rooms.append(load(queued_rooms[LevelsList.proloque_level_maps[i]]).instantiate())
		#i+=1
		
	loaded_rooms.append(load(queued_rooms[0]).instantiate())
	
	loaded_rooms.append(load(queued_rooms[1]).instantiate())
	loaded_rooms.append(load(queued_rooms[2]).instantiate())
	loaded_rooms.append(load(queued_rooms[2]).instantiate())
	loaded_rooms.append(load(queued_rooms[3]).instantiate())
	loaded_rooms.append(load(queued_rooms[2]).instantiate())
	loaded_rooms.append(load(queued_rooms[1]).instantiate())
	loaded_rooms.append(load(queued_rooms[3]).instantiate())
	loaded_rooms.append(load(queued_rooms[1]).instantiate())
	
	loaded_rooms.append(load(queued_rooms[4]).instantiate())

func load_first_room (_transition_in : String="fade_to_black", \
	_transition_out : String="fade_from_black") -> void:
		
	world_2d.add_child(loaded_rooms_map["prologue"])
	player.reparent(loaded_rooms_map["prologue"])
	loaded_rooms_map["prologue"].player.global_position=loaded_rooms_map["prologue"].init_starting_pos.global_position
	LevelTransition.transition_out(_transition_out)
	current_2d_scene=loaded_rooms_map["prologue"]


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
	print(loaded_rooms_map[new_scene].starting_pos.size(), " ",_starting_pos)
	loaded_rooms_map[new_scene].player.global_position=loaded_rooms_map[new_scene].starting_positions[_starting_pos]
	LevelTransition.transition_out(_transition_out)
	prev_2d_scene=current_2d_scene
	current_2d_scene=loaded_rooms_map[new_scene]
	return_room=prev_2d_scene.name
	load_levels(LevelsList.proloque_level_maps)




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


func _on_player_update_health(value : int) -> void:
	ui_level.set_health(value)


func _on_player_update_max_health(value : int) -> void:
	ui_level.set_max_health(value)
