class_name adv_level

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

@onready var cutscene_player: AnimationPlayer = $CutscenePlayer
var qte_options : Array[String]

@export var lvl_type = "goal"
@onready var boss_dead : bool = false

var cur_state = "IDLE"
var cur_health = 3
var max_health = 3
var elite_spawn_flag : bool = false
var boss_spawn_flag : bool = false

var spawn_type : Array[String] = ["enemy", "boss"]

var obj : int

func _ready():
	if not next_level is PackedScene:
		next_level = load("res://LVL_Transitions/victory_screen.tscn")
		
		
	RenderingServer.set_default_clear_color(Color.BLACK)
	#polygon_2d.polygon = collision_polygon_2d.polygon
	#Events.level_completed.connect(show_level_complete)
	Events.game_over.connect(show_game_over)
	Events.boss_died.connect(boss_died)
	Events.pause.connect(show_pause)
	Events.unpause.connect(unpause)
	Events.inc_score.connect(inc_score)

	Events.start_cutscene.emit()
	cutscene_player.play("INTRO")
	
	
	#score=45
func _process(_delta):
	
	obj = (get_tree().get_nodes_in_group("Hearts").size()) + (get_tree().get_nodes_in_group("Enemy").size())
	
	get_state()
	set_state()
	get_health()
	set_health()
	
	if lvl_type=="goal":
	
		if obj<=1:
			Events.level_completed.connect(show_level_complete)
			#print("leven complete")
		label.text=str("Obj: ",obj)
	elif lvl_type=="adv":
		Events.level_completed.connect(show_level_complete)
	else:
		label.text = str("Score: ", score)
		handle_spawn()
		if Input.is_action_just_pressed("Pause"):
			show_pause()


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
	
	
func get_state():
	cur_state = PC.get_state()
	
	
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

func handle_spawn():
	pass

func end_cutscene():
	Events.end_cutsene.emit()
	
func boss_died():
	Events.level_completed.emit()

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
