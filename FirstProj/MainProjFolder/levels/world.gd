extends Node2D

@export var next_level: PackedScene

#@onready var collision_polygon_2d = $StaticBody2D/CollisionPolygon2D
#@onready var polygon_2d = $StaticBody2D/CollisionPolygon2D/Polygon2D
@onready var level_completed = $CanvasLayer/LevelCompleted
@onready var game_over = $CanvasLayer/GameOver
@onready var PC = $PC
@onready var ui_level = $CanvasLayer/UI_Level
@onready var label = $CanvasLayer/Label
@onready var pause_menu = $CanvasLayer/PauseMenu
@onready var score : int = 0
@onready var heat_handler: HeatHandler = $HeatHandler


#Cutscenes
@onready var cutscene_player: AnimationPlayer = $CutscenePlayer
var qte_options : Array[String] = ["1","1","1","1","1"]


@export var lvl_type = "goal"
@export var elite_spawn : int = 20
@export var boss_spawn : int = 40

@export var player : PlayerEntity
@onready var camera_pos: camera_position = $CameraPos
@export var starting_pos: Array[Node2D]
@onready var default: Node2D = $StartingPos/Default
signal get_entry_position

@onready var cutscene_active : bool = false

var cur_state = "IDLE"
var cur_health = 3
var max_health = 3
var elite_spawn_flag : bool = false
var boss_spawn_flag : bool = false

var spawn_type : Array[String] = ["enemy", "boss"]
var spawn_points

var obj : int

var init_active_enemies_list : Array[Node]

## Called when the node enters the scene tree for the first time.
func _ready():
	if not next_level is PackedScene:
		next_level = load("res://LVL_Transitions/victory_screen.tscn")
	#print(starting_pos[0].global_position)
	
	RenderingServer.set_default_clear_color(Color.BLACK)
	#polygon_2d.polygon = collision_polygon_2d.polygon
	#Events.level_completed.connect(show_level_complete)
	Events.game_over.connect(show_game_over)
	Events.pause.connect(show_pause)
	Events.unpause.connect(unpause)
	Events.inc_score.connect(inc_score)
	#GlobalSaveData.save_game()
	
	spawn_points = get_tree().get_nodes_in_group("SpawnPoint")
	heat_handler.heat_lvl_spawn()
	for i in spawn_points.size():
		print(spawn_points[i].name)
	#Events.start_cutscene.emit()
	#Events.end_cutsene.connect(end_cutscene)
	#Events.queue_cutscene.emit(Cutscenes.intro_cutscene)
	#score=45
	init_active_enemies_list = get_tree().get_nodes_in_group("Enemy")
	if lvl_type=="adv":
		cutscene_player.play("TEST")
	else:
		Events.spawn_update.emit(enemy_list.REG_ENEMIES, true)
		end_cutscene()
	
func _process(_delta):
	
	obj = (get_tree().get_nodes_in_group("Hearts").size()) + (get_tree().get_nodes_in_group("Enemy").size())
	
	set_state()
	get_health()
	set_health()
	
	if Input.is_action_just_pressed("DEBUG_KEY"):
		#save_level_state()
		load_level_state()
	
	if lvl_type=="goal":
	
		if obj<=1:
			Events.level_completed.connect(show_level_complete)
			#print("leven complete")
		label.text=str("Obj: ",obj)
	else:
		label.text = str("Score: ", score)
		
		handle_spawn()
	
	if Input.is_action_just_pressed("Pause"):
		show_pause()
	
func _physics_process(delta: float) -> void:
	if not cutscene_active and not camera_pos.stationary:
		camera_pos.global_position=Vector2(player.global_position.x, player.global_position.y-50)
	
func save_level_state():
	var _save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var persistant_nodes : Array[Node] =get_tree().get_nodes_in_group("Persistant")
	for node in persistant_nodes:
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue
		if !node.has_method("save_state"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue
		node.call("save_state")
	var _active_enemies_list : Array[Node] = get_tree().get_nodes_in_group("Enemy")
	var _active_enemy_names : Array[StringName]
	for _node in _active_enemies_list:
		_active_enemy_names.push_back(_node.name)
	var _active_enemies_json=JSON.stringify(_active_enemy_names)
	print(_active_enemies_json)
	_save_file.store_line(_active_enemies_json)
	Events.checkpoint_reached.emit()


func load_level_state():
#	Update enemies to remove enemies from tree that are no longer active, based on what was saved
	var _save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	var _active_enemy_list : Array
	while _save_file.get_position() < _save_file.get_length():
		var _json_string = _save_file.get_line()
		var _json = JSON.new()
		var _parse_result = _json.parse(_json_string)
		if not _parse_result == OK:
			print("JSON Parse Error: ", _json.get_error_message(), " in ", _json_string, " as line ", _json.get_error_line())
			continue
		var _parse_data=_json.data
		if typeof(_parse_data)==TYPE_ARRAY:
			_active_enemy_list=_parse_data
	for _enemy in init_active_enemies_list:
		if is_instance_valid(_enemy):
			if _active_enemy_list.has(_enemy.name):
				continue
			else:
				_enemy.queue_free()
				
#	Update persistant objects sates based on what was saved
	GlobalSaveData.load_game()
	Events.load_checkpoint.emit()
		

func show_level_complete():

	
	level_completed.show()
	get_tree().paused = true
	if not next_level is PackedScene: return
	
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
	LevelTransition.fade_from_black()
	
func show_game_over():
	game_over.show()
	get_tree().paused = true

func show_pause():
	pause_menu.show()
	get_tree().paused = true
	
func unpause():
	pause_menu.hide()
	get_tree().paused = false
	
	
#func get_state():
	#cur_state = PC.get_state()
	#
	
func set_state():
	ui_level.set_cur_state(cur_state)
	
func get_health():
	cur_health = PC.get_health()
	max_health = PC.get_max_health()
	
func set_health():
	ui_level.set_health(cur_health)
	ui_level.set_max_health(max_health)
	
func inc_score():
	score += 1
	if ui_level.heat_lvl<6:
		ui_level.heat_lvl+=1
	else:
		ui_level.heat_lvl=0
		ui_level.heat_fill+=1

func handle_spawn():
	
	if score>=20 and score<40:
		if elite_spawn_flag == false:
			print("adding mech")
			#Events.spawn_update.emit(enemy_list.BOSSES, true)
			elite_spawn_flag = true
			
	elif score>=40:
		if boss_spawn_flag == false:
			#print("boss spawn")
			Events.deactivate.emit(spawn_type[0])
			#Events.deactivate.emit(spawn_type[1])
			var enemy_cnt = get_tree().get_nodes_in_group("Enemy").size()
			if enemy_cnt==0:
				print("boss activate")
				boss_spawn_flag=true
				Events.activate.emit(spawn_type[1])



		

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func end_cutscene():
	Events.end_cutsene.emit()

func start_qte(qte_time : int):
	Events.start_qte.emit(qte_time)

func play_cutscene(_cutscene : String):
	Events.play_cutscene_segment.emit(_cutscene)

func load_qte_animations(atk_opt : String, dodge_opt : String, block_opt : String, spc_atk_opt : String, no_input : String):
	qte_options[0]=atk_opt
	qte_options[1]=dodge_opt
	qte_options[2]=block_opt
	qte_options[3]=spc_atk_opt
	qte_options[4]=no_input
	
	
	
	

func _on_pc_attack_qte() -> void:
	cutscene_player.queue(qte_options[0])


func _on_pc_block_qte() -> void:
	cutscene_player.queue(qte_options[1])


func _on_pc_dodge_qte() -> void:
	cutscene_player.queue(qte_options[2])


func _on_pc_special_atk_qte() -> void:
	cutscene_player.queue(qte_options[3])


func _on_pc_no_input_qte() -> void:
	cutscene_player.queue(qte_options[4])


func _on_ui_level_aaeat_lvl_raise() -> void:
	print("HEAT RISING")
	ui_level.heat_fill+=1
	heat_handler.heat_lvl_spawn()
