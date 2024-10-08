extends Node2D

@export var next_level: PackedScene

#@onready var collision_polygon_2d = $StaticBody2D/CollisionPolygon2D
#@onready var polygon_2d = $StaticBody2D/CollisionPolygon2D/Polygon2D
@onready var level_completed = $CanvasLayer/LevelCompleted
@onready var game_over = $CanvasLayer/GameOver
@onready var PC = $PC
@onready var ui_level = $CanvasLayer/UI_Level
@onready var label = $CanvasLayer/Label


var cur_state = "IDLE"
var cur_health = 3

var obj : int

## Called when the node enters the scene tree for the first time.
func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	#polygon_2d.polygon = collision_polygon_2d.polygon
	#Events.level_completed.connect(show_level_complete)
	Events.game_over.connect(show_game_over)
	
	
	
	
func _process(_delta):
	
	obj = (get_tree().get_nodes_in_group("Hearts").size()) + (get_tree().get_nodes_in_group("Enemy").size())
	
	get_state()
	set_state()
	get_health()
	set_health()
	if obj<=1:
		Events.level_completed.connect(show_level_complete)
	label.text=str("Obj: ",obj)
	
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

	
	
func get_state():
	cur_state = PC.get_state()
	
	
func set_state():
	ui_level.set_cur_state(cur_state)
	
func get_health():
	cur_health = PC.get_health()
	
func set_health():
	ui_level.set_health(cur_health)
#


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
