class_name GameController extends Node

signal player_data_retrieved
signal player_pos_reset_to_checkpoint

@onready var world_2d: Node2D = $World2D

@export var gui : Control

#@onready var player: PlayerEntity = $World2D/Player
@onready var pause_menu: Control = $GUI/CanvasLayer/PauseMenuv2
@onready var gameui: Control = $GUI/CanvasLayer/GAMEUI
@onready var ui_level: Control = $GUI/CanvasLayer/GAMEUI/UI_Level
@onready var objectives_ui: objective_ui = $GUI/CanvasLayer/PauseMenuv2/TextureRect/MainPause/ObjectivesUI
@onready var level_UI: CanvasLayer = $GUI/CanvasLayer
@onready var game_over: ColorRect = $GUI/CanvasLayer/GameOver
@onready var dialogue_box_controller: DialogueBoxController = $GUI/CanvasLayer/DialogueBoxController



#@onready var levels: Levels = $Levels
@onready var queued_rooms : Array[String] = []
@onready var loaded_rooms : Array[Node] = []
@onready var loaded_rooms_map : Dictionary
@onready var current_room : int = 0
@onready var return_room : String = ""

#Region of levels to load into memory
@onready var region : Dictionary

var current_2d_scene
var prev_2d_scene
var current_gui_scene
@onready var new_gui_level := preload(LevelList.MAIN_MENU).instantiate()
@onready var prev_gui_scene = "NONE"
var thread: Thread
var mutex: Mutex

#@onready var prologue_lvl: adv_level = $World2D/PrologueLvl

func _ready() -> void:	
	#print_debug(OS.get_processor_count())
	mutex = Mutex.new()
	thread = Thread.new()
	call_preload_scene(LevelsList.LEVEL_SELECT)
	Global.game_controller = self
	Events.load_level_map.connect(load_levels)
	Events.load_first_level.connect(load_first_room)
	Events.toggle_game_ui.connect(toggle_game_ui)
	Events.load_objectives.connect(_init_objectives)
	Events.toggle_level_processing.connect(toggle_world2d_process)
	Events.load_menu_scene.connect(change_gui_scene)
	Events.reload_level_checkpoint.connect(reload_from_checkpoint)
	
	Events.pause.connect(show_pause)
	Events.unpause.connect(unpause)
	
	#Disables game UI and level process when first starting
	#toggle_game_ui(false)
	#toggle_world2d_process(false)
	#toggle_player(false)
	
	#test_start()
	change_gui_scene(LevelList.MAIN_MENU)
	level_UI.visible=false
	
	
func _process(delta: float) -> void:
	#assert(player != null)
	if Input.is_action_just_pressed("Pause"):
		show_pause()

#For force starting levels to test
func test_start() -> void:
	load_levels(LevelsList.prologue_unique_levels)
	load_first_room("PrologueLvl")
	prev_2d_scene=current_2d_scene
	#current_2d_scene.player=player
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
	
func show_game_over(value: String):
	current_2d_scene.set_process(false)
	game_over.show()
	

func set_region (dict : Dictionary) -> void:
	region=dict

#refactor to use global array/map of full levels
func load_levels(dict : Dictionary) -> void:
	
	mutex.lock()
	for room in dict:
		#print_debug(room)
		#print_debug(dict[room])
		if loaded_rooms_map.has(room) == false:
			loaded_rooms_map[room]=load(dict[room]).instantiate()
		#loaded_rooms.append(load(dict[room]).instantiate())
		#i+=1
	mutex.unlock()
	
func call_preload_levels(_dict : Dictionary):
	thread.start(load_levels.bind(_dict))
	thread.call_deferred("wait_to_finish")
	print("scenes loaded")
	#call_deferred("scene_loaded")
	
#func adjacent_rooms_loaded()-> void:
	#thread.wait_to_finish()
	#print_debug("rooms preloaded")


func reload_game() -> void:
	get_tree().reload_current_scene()
		
func reload_from_checkpoint(_transition_in : String="fade_to_black", \
	_transition_out : String="fade_from_black") -> void:
	#var _reload_scene=current_2d_scene.name
	world_2d.call_deferred("remove_child", current_2d_scene) #removes_node
	await current_2d_scene.tree_exited
	world_2d.add_child(current_2d_scene)
	GlobalSaveData.load_persistant_data()
	
	#current_2d_scene=_reload_scene
	Events.get_player_data.emit()
	reset_player_pos_checkpoint()
	#await self.player_pos_reset_to_checkpoint
	retrieve_player_data()
	#await self.player_data_retrieved
	#current_2d_scene.reload_scene()
	##await current_2d_scene.scene_reloaded
	#LevelTransition.transition_out(_transition_out)
	#game_over.hide()

func _on_player_pos_reset_to_checkpoint(_transition_out : String="fade_from_black") -> void:
	current_2d_scene.reload_scene()
	#await current_2d_scene.scene_reloaded
	LevelTransition.transition_out(_transition_out)
	game_over.hide()



func reset_player_pos_checkpoint() -> void:
	current_2d_scene.player.global_position=Vector2(GlobalSaveData.current_save["player"]["pos_x"], GlobalSaveData.current_save["player"]["pos_y"])
	#current_2d_scene.camera_pos.global_position=current_2d_scene.player.global_position
	player_pos_reset_to_checkpoint.emit()

#Load first scene on game start
func load_first_room (_first_room : String, \
	_transition_in : String="fade_to_black", \
	_transition_out : String="fade_from_black") -> void:
		
	world_2d.add_child(loaded_rooms_map[_first_room])
	#player.reparent(loaded_rooms_map[_first_room])
	loaded_rooms_map[_first_room].player.global_position=loaded_rooms_map[_first_room].init_starting_pos.global_position
	LevelTransition.transition_out(_transition_out)
	current_2d_scene=loaded_rooms_map[_first_room]

#Toggle UI vissibility
func toggle_game_ui(value : bool) -> void:
	level_UI.set_deferred("visible", value)
	
#Toggle world2D, the main level processing tree, processing
func toggle_world2d_process(value : bool) -> void:
	world_2d.set_process(value)
	world_2d.visible=value

#Load single scene
func load_cutscene(new_scene: String, \
	delete: bool = true, \
	keep_running: bool = false, \
	_transition_in : String="fade_to_black", \
	_transition_out : String="fade_from_black") -> void:
	
	#await LevelTransition.transition_in(_transition_in)
	toggle_game_ui(false)
	if current_2d_scene != null:
		if delete:
			current_2d_scene.queue_free() #Deletes node entirely
		elif keep_running:
			current_2d_scene.visible = false #Keep in mem and running
		else:
			world_2d.call_deferred("remove_child", current_2d_scene)
			
			
	var _new_2d_scene=load(LevelsList.adv_cutscenes[new_scene]).instantiate()
	if world_2d.get_child_count()==0:
		world_2d.add_child(_new_2d_scene)
		
	if current_2d_scene != null:
		prev_2d_scene=current_2d_scene
		return_room=prev_2d_scene.name
	current_2d_scene=_new_2d_scene
	LevelTransition.transition_out(_transition_out)
	
#Change scenes
func change_2d_scene (new_scene: String, \
	delete: bool = true, \
	keep_running: bool = false, \
	_starting_pos: int = -1, \
	_transition_in : String="fade_to_black", \
	_transition_out : String="fade_from_black") -> void:
	
	if current_2d_scene!=null:
		if loaded_rooms_map[new_scene].name == current_2d_scene.name:
			return
	
	#player.reparent(world_2d)
	await LevelTransition.transition_in(_transition_in)
	if current_2d_scene != null:
		if delete:
			current_2d_scene.queue_free() #Deletes node entirely
			await current_2d_scene.tree_exited
		elif keep_running:
			current_2d_scene.visible = false #Keep in mem and running
		else:
			world_2d.call_deferred("remove_child", current_2d_scene)
	
	if new_scene=="RETURN":
		new_scene=return_room
	
	if world_2d.get_child_count()==0:
		world_2d.add_child(loaded_rooms_map[new_scene])
	#player.reparent(loaded_rooms_map[new_scene])
	
	#Starting position is -1 if scene has no starting position
	if _starting_pos==-1:
		loaded_rooms_map[new_scene].player.global_position=loaded_rooms_map[new_scene].init_starting_pos.global_position
	else:
		#print_debug(loaded_rooms_map[new_scene].starting_pos.size(), " ",_starting_pos)
		loaded_rooms_map[new_scene].player.global_position=loaded_rooms_map[new_scene].starting_pos[_starting_pos]
		
	LevelTransition.transition_out(_transition_out)
	if current_2d_scene != null:
		prev_2d_scene=current_2d_scene
		return_room=prev_2d_scene.name
	current_2d_scene=loaded_rooms_map[new_scene]
	Events.get_player_data.emit()
	retrieve_player_data()
	Events.retrieve_heat_stats.emit()

	load_levels(LevelsList.level_maps)

func _init_objectives(_dict : Dictionary):
	objectives_ui._init_objectives_list(_dict)
	
#Change GUI Scene
func change_gui_scene (new_scene: String, \
	delete: bool = true, \
	keep_running: bool = false, \
	_transition_in : String="fade_to_black", \
	_transition_out : String="fade_from_black") -> void:
	LevelTransition.transition_in(_transition_in)
	if current_gui_scene != null:
		prev_gui_scene=current_gui_scene
		gui.call_deferred("remove_child", current_gui_scene)
	current_gui_scene=new_gui_level
	gui.add_child(current_gui_scene)
	LevelTransition.transition_out(_transition_out)
	

# preload next scene, if not already loaded
func preload_scene(_new_scene: String):
	mutex.lock()
	new_gui_level=load(_new_scene).instantiate()
	mutex.unlock()
	
func call_preload_scene(_new_scene: String):
	thread.start(preload_scene.bind(_new_scene))
	call_deferred("scene_loaded")
	
func scene_loaded()-> void:
	thread.wait_to_finish()
	print_debug("thread_finished")

#remove world2d, for moving to menu only scene
func remove_world2d_scene() -> void:
	#player.call_deferred("reparent", world_2d)
	world_2d.call_deferred("remove_child", current_2d_scene)
	#player.call_deferred("set_process", false)

func remove_gui_scene (delete: bool = true, \
	keep_running: bool = false, \
	_transition_in : String="fade_to_black", \
	_transition_out : String="fade_from_black") -> void:
	await LevelTransition.transition_in(_transition_in)
	if current_gui_scene!=null:
		gui.call_deferred("remove_child", current_gui_scene)
	
func add_gui_to_existing(new_gui: String) -> void:
	var _new_gui_scene=load(new_gui).instantiate()
	gameui.add_child(_new_gui_scene)
	
func remove_gui_from_existing(gui_name : String) -> void:
	var _node=get_tree().get_first_node_in_group(gui_name)
	if _node!=null:
		gameui.call_deferred("remove_child", _node)
	
func toggle_dialogue(_visible : bool) -> void:
	dialogue_box_controller.set_deferred("visible", _visible)

#func toggle_player(activate : bool) -> void:
	#if activate:
		#if world_2d.has_node(player.get_path()):
			#pass
		#else:
			#world_2d.add_child(player)
	#else:
		#if world_2d.has_node(player.get_path()):
			#world_2d.call_deferred("remove_child", player)
		#else:
			#pass
		#

#func _on_player_update_health(value : int) -> void:
	#ui_level.set_health(value)
#
#
#func _on_player_update_max_health(value : int) -> void:
	#ui_level.set_max_health(value)

func update_health(value : int) -> void:
	ui_level.set_health(value)
	
func update_max_health(value : int) -> void:
	ui_level.set_max_health(value)

func update_stagger(value : int) -> void:
	ui_level.set_stagger(value)

func update_max_stagger(value : int) -> void:
	ui_level.set_max_stagger(value)

func retrieve_player_data() -> void:
	ui_level.set_health(GlobalSaveData.current_save["player"]["health"])
	ui_level.set_max_health(GlobalSaveData.current_save["player"]["max_health"])
	ui_level.set_stagger(GlobalSaveData.current_save["player"]["stagger"])
	ui_level.set_max_stagger(GlobalSaveData.current_save["player"]["max_stagger"])
	player_data_retrieved.emit()
	
