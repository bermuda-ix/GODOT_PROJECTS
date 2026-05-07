class_name adv_level

extends Node2D

signal scene_reloaded

@export var next_level: PackedScene

@export var player : PlayerEntity
@onready var cutscene_active : bool = false
#@onready var init_starting_pos: Node2D = $DoorsAndSwitches/Entries/StartingPos
@onready var init_starting_pos: Node2D = $StartingPos/Default
@onready var camera_pos: camera_position = $CameraPos
@onready var camera_2d: Camera2D = $CameraPos/Camera2D	
@export var camera_offset_y : int = 0
@export var pc_scale : float = 1

#Camera settings
var camera_zoom : float = 1.0
var camera_offset : Vector2 = Vector2.ZERO
var camera_stationary : bool = false


#@onready var collision_polygon_2d = $StaticBody2D/CollisionPolygon2D
#@onready var polygon_2d = $StaticBody2D/CollisionPolygon2D/Polygon2D
@onready var level_completed = $CanvasLayer/LevelCompleted
@onready var game_over = $CanvasLayer/GameOver
@onready var PC = $PC
@onready var ui_level = $CanvasLayer/UI_Level
@onready var label = $CanvasLayer/Label
@onready var pause_menu = $CanvasLayer/PauseMenu
@onready var score : int = 0
@onready var starting_pos: Array[Vector2]
#@onready var starting_positions : Dictionary = {}
@onready var persistent_data_handler: PersistentDataHandler = $PersistentDataHandler
@onready var heat_handler: HeatHandler = $HeatHandler


@export var lvl_type = "goal"
@export var main_room : bool = false
@onready var boss_dead : bool = false


@export_category("Cutscene Variables")
@onready var cutscene_player: AnimationPlayer = $CutscenePlayer
@export var intro_cutscene_active : bool = false
var qte_options : Array[String]  = ["1", "2", "3", "4", "0"]
@onready var player_transform: RemoteTransform2D = $Paths/Path2D/PathFollow2D/PlayerTransform
@onready var hit_stop: HitStop = $HitStop
@export var cutscene_library : String
@export var skippable : bool = true
@onready var cutscene_queue : Array[String]
@onready var cutscene_queue_index : int = 0
@onready var dialogue_box_controller: DialogueBoxController = $CanvasLayer/DialogueBoxController



###MiniBoss1Nodes
@onready var mini_boss_right_boundery_col: CollisionShape2D = $Bounderies3/MiniBoss1Bounderies/MiniBossRightBoundery/MiniBossRightBounderyCol
@onready var mini_boss_1_start_pos: Node2D = $Enemy/MiniBosses/MinoBossGroup1/MiniBoss1StartPos
@onready var soldier_enemy_boss: SoldierEnemyBoss = $Enemy/MiniBosses/MinoBossGroup1/soldier_enemy_boss




var cur_state = "IDLE"
var cur_health = 3
var max_health = 3
var elite_spawn_flag : bool = false
var boss_spawn_flag : bool = false

var spawn_type : Array[String] = ["enemy", "boss"]
var spawns_present : bool

var spawn_points : Array

var obj : int

func _ready():
	
	if main_room:
		LevelsList.level_maps[self.name] = self.scene_file_path
	
	if not next_level is PackedScene:
		next_level = load("res://LVL_Transitions/victory_screen.tscn")
		
	if lvl_type=="adv":
		Events.level_completed.connect(show_level_complete)
	RenderingServer.set_default_clear_color(Color.BLACK)
	#polygon_2d.polygon = collision_polygon_2d.polygon
	Events.level_completed.connect(show_level_complete)
	Events.game_over.connect(show_game_over)
	Events.boss_died.connect(boss_died)
	#Events.pause.connect(show_pause)
	#Events.unpause.connect(unpause)
	Events.inc_score.connect(inc_score)
	#Events.increase_heat_lvl.connect(increase_heat)
	load_cutscene_queue(Cutscenes.Cutscenes["MiniBoss1"])
	
	
	if player == null:
		player=get_tree().get_first_node_in_group("player")
	
	player.attack_qte.connect(_pc_attack_qte)
	player.block_qte.connect(_pc_block_qte)
	player.dodge_qte.connect(_pc_dodge_qte)
	player.special_atk_qte.connect(_pc_special_atk_qte)
	player.no_input_qte.connect(_pc_no_input_qte)
	
	player.scale = Vector2(pc_scale, pc_scale)
	
	if init_starting_pos!=null:
		player.global_position=init_starting_pos.global_position
	
	if intro_cutscene_active:
		Events.start_cutscene.emit()
		cutscene_player.play("INTRO")
	var entries=get_tree().get_nodes_in_group("entry")
	starting_pos.resize(entries.size())
	for entry in entries:
		#starting_positions[entry.entry]=entry.global_position
		starting_pos[entry.entry]=entry.global_position
	
	if not cutscene_active and not camera_pos.stationary:
		camera_pos.global_position=Vector2(player.global_position.x, player.global_position.y-40)
		camera_pos.set_cam_smooth(true)
	
	#Ready up spawns
	if get_tree().get_nodes_in_group("SpawnPoints").is_empty():
		spawns_present=false
	else:
		spawns_present=true
		spawn_points=get_tree().get_nodes_in_group("SpawnPoints")
	
	player.init_player_data()
	
	
func _process(_delta):
	
	obj = (get_tree().get_nodes_in_group("Hearts").size()) + (get_tree().get_nodes_in_group("Enemy").size())
	
	if cutscene_active:
		dialogue_continue()
	


func _physics_process(delta: float) -> void:
	if not cutscene_active and not camera_pos.stationary:
		camera_pos.global_position=Vector2(player.global_position.x, player.global_position.y-camera_offset_y)

func show_level_complete():

	
	level_completed.show()
	get_tree().paused = true
	if not next_level is PackedScene: return
	
	await LevelTransition.fade_to_black()
	get_tree().paused = false
	get_tree().change_scene_to_packed(next_level)
	LevelTransition.fade_from_black()

func show_game_over():
	Global.game_controller.show_game_over(name)
	get_tree().paused = true

#func show_pause():
	#pause_menu.show()
	#get_tree().paused = true
	#
#func unpause():
	#pause_menu.hide()
	#get_tree().paused = false
	#
	

func get_state():
	cur_state = player.get_state()
	
	
func set_state():
	ui_level.set_cur_state(cur_state)
	
func get_health():
	cur_health = player.get_health()
	max_health = player.get_max_health()
	
func set_health():
	ui_level.set_health(cur_health)
	ui_level.set_max_health(max_health)
	
func inc_score(value : int):
	score += 1

func set_max_heat(_value : int) -> void:
	heat_handler.max_heat_level=_value

func toggle_spawn(_value : bool, _enemy_type) -> void:
	var _spawn_points := get_tree().get_nodes_in_group("SpawnPoint")
	if _value:
		for i in range(_spawn_points.size(), 0, -1):
			_spawn_points[i].activate(_enemy_type)
	else:
		for i in range(_spawn_points.size(), 0, -1):
			_spawn_points[i].deactivate(_enemy_type)

func handle_spawn():
	pass

func dialogue_flag_listener(_dialogue) -> void:
	pass

########################
###Cutscene Functions###
########################

func play_cutscene_segment(_cutscene_segment : String):
	var _cutscene=cutscene_library+"/"+_cutscene_segment
	Events.play_cutscene_segment.emit(_cutscene)
	cutscene_player.play(_cutscene)

func load_cutscene_queue(_cutscene_list_rec : String):
	var _cutscene_list : CutsceneQueue = load(_cutscene_list_rec)
	#print_debug(_cutscene_list.cutscene_list)
	cutscene_queue.assign(_cutscene_list.cutscene_list)

func play_cutscene_queue():
	Events.start_cutscene.emit()
	cutscene_active=true
	cutscene_player.play(cutscene_queue[cutscene_queue_index])

func dialogue_continue():
	if (Input.is_action_just_pressed("attack")\
	 or Input.is_action_just_pressed("jump")\
	 or Input.is_action_just_pressed("Interact")):
		if (dialogue_box_controller.playing_bot or dialogue_box_controller.playing_top):
			if skippable:
				cutscene_player.stop(true)
				dialogue_box_controller.skip_to_end()
			else:
				pass
		elif not cutscene_player.is_playing():
			
			if cutscene_queue_index>=cutscene_queue.size():
				print_debug("end_of_scene")
			else:
				cutscene_queue_index+=1
				cutscene_player.play(cutscene_queue[cutscene_queue_index])
		else:
			pass
			

func end_cutscene():
	Events.end_cutsene.emit()
	dialogue_box_controller.hide_both()
	cutscene_active=false
	
#################################
###Dialogue Cutscene Functions###
#################################
	
func cutscene_wait_for_input() -> void:
	cutscene_player.pause()

func toggle_skip(value : bool) -> void:
	skippable=value
	

func boss_died(cutscene: String):
	Events.start_cutscene.emit()
	var _cutscene=cutscene_library+"/"+cutscene
	cutscene_player.play(_cutscene)
	hit_stop.hit_stop(0.5,0.5)
	cutscene_active=true

func end_level():
	Events.level_completed.emit()

func load_qte_animations(atk_opt : String, dodge_opt : String, block_opt : String, spc_atk_opt : String, no_input : String):
	qte_options[0]=atk_opt
	qte_options[1]=dodge_opt
	qte_options[2]=block_opt
	qte_options[3]=spc_atk_opt
	qte_options[4]=no_input
	
func attach_path():
	if has_node(player_transform.get_path()):
		var _player = get_tree().get_first_node_in_group("player")
		player_transform.remote_path = _player.get_path()
	else:
		return

func remove_path():
	player_transform.remote_path = ""

func toggle_intro_cutscene(_value : bool):
	intro_cutscene_active=_value

func _pc_attack_qte() -> void:
	cutscene_player.queue(qte_options[0])
	
func _pc_block_qte() -> void:
	cutscene_player.queue(qte_options[1])

func _pc_dodge_qte() -> void:
	cutscene_player.queue(qte_options[2])

func _pc_special_atk_qte() -> void:
	cutscene_player.queue(qte_options[3])


func _pc_no_input_qte() -> void:
	cutscene_player.queue(qte_options[4])


func _on_external_door_switch_unlock_door() -> void:
	pass # Replace with function body.

func toggle_ui(_value : bool) -> void:
	Global.game_controller.toggle_game_ui(_value)

func reload_scene():
	camera_pos.camera_zoom=camera_zoom
	assert(camera_pos.camera_zoom==camera_zoom)
	camera_pos.offset=camera_offset
	camera_pos.stationary=camera_stationary
	var _bosses = get_tree().get_nodes_in_group("Boss")
	for boss in _bosses:
		boss.boss_reset()
		boss.global_position=mini_boss_1_start_pos.global_position
	var _boss_boundaries = get_tree().get_nodes_in_group("boss_boundary")
	for _boss_boundary in _boss_boundaries:
		_boss_boundary.call_deferred("set_disabled", true)
	var _flags = get_tree().get_nodes_in_group("group_1_flags")
	for _flag in _flags:
		_flag.flag_active=true
		_flag.collision_shape_2d.call_deferred("set_disabled", false)
		_flag.flag_reset()
	scene_reloaded.emit()
		

func _on_mini_boss_1_flag_flag_triggered() -> void:
	mini_boss_right_boundery_col.call_deferred("set_disabled", true)
	#mini_boss_right_boundery_col.disabled=false
	cutscene_player.play("Mini_Boss_Start")
	soldier_enemy_boss.boss_ui.visible=true
	soldier_enemy_boss.global_position=mini_boss_1_start_pos.global_position
	soldier_enemy_boss.boss_activate()
	#camera_pos.stationary=true
	
func boss_start() -> void:
	pass

func _on_scene_reloaded() -> void:
	var _boss_boundaries = get_tree().get_nodes_in_group("boss_boundary")
	for _boss_boundary in _boss_boundaries:
		assert(_boss_boundary.disabled==true)
