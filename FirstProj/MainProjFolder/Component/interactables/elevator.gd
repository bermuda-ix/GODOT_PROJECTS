extends Node2D

@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D
@onready var pause_move: Timer = $PauseMove
@onready var resume: Timer = $Resume
@onready var path_2d: Path2D = $Path2D

@onready var button_panel: Area2D = $Path2D/PathFollow2D/StaticBody2D/ButtonPanelSprite/ButtonPanel
@onready var panel_active : bool = false
@onready var elevator_button = preload("res://Component/interactables/elevator_button.tscn")
@onready var elevator_ui: Control = $Path2D/PathFollow2D/StaticBody2D/ElevatorUI
@onready var scroll_container: ScrollContainer = $Path2D/PathFollow2D/StaticBody2D/ElevatorUI/PanelContainer/ScrollContainer
@onready var elevator_buttons: VBoxContainer = $Path2D/PathFollow2D/StaticBody2D/ElevatorUI/PanelContainer/ScrollContainer/ElevatorButtons



@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var automatic : bool = false

#floors
@export_category("Floor Variables")
@onready var bottom_floor : float = 0
@onready var current_floor : float = 0.0
@onready var next_floor : float = 0.0
@export var top_floor : float =-400
@export var floors : Array[float]
@export var init_floor : int = 0
@export var locked_floors : Array[int]


#Stops based on progress_ratio
#@export var stops_ratio : Array[float]

var open_flag : bool = true
var stopped : bool = false
var going_up : bool = true

func _ready() -> void:
	path_2d.curve.set_point_out(1, Vector2(0,top_floor))
	#Push bottom floor and top floor into floors array as 0 and 1 ratio
	floors.push_front(0.0)
	floors.push_back(1.0)
	add_floor_buttons()
	current_floor=floors[init_floor]
	resume.start(3)
	Events.open_interact_menu.connect(open_elevator_menu)
	
func _physics_process(delta: float) -> void:
	#print(snapped(path_follow_2d.progress_ratio, 0.1), " , ", going_up)
	move_to_floor()

	
		


func open():
	open_flag=true

func add_floor_buttons():
	
	print("This elevator has " + str(floors.size()) + " floors at:")
	for i in range(floors.size()):
		var _new_elevator_button = elevator_button.instantiate()
		_new_elevator_button.button_text = str(floors.size()-(i+1))
		if locked_floors.has(floors.size()-(i+1)):
			_new_elevator_button.toggle_floor_lock(true)
		_new_elevator_button.floor.connect(self.choose_floor)
		_new_elevator_button.name = "Floor " + str(floors.size()-(i+1))
		print(_new_elevator_button.button_text)
		elevator_buttons.add_child(_new_elevator_button)
		

#for automaticallly moving elevators
func _on_pause_move_timeout() -> void:
	stopped=false
	resume.start(0.5)
	
func choose_floor(_floor : int) -> void:
	if stopped:
		current_floor = path_follow_2d.progress_ratio
		next_floor = floors[_floor]
		if current_floor<next_floor:
			print("Moving up to floor ", _floor)
			going_up=true
			animation_player.play("start_moving")
		elif current_floor>next_floor:
			print("Going down to floor ", _floor)
			going_up=false
			animation_player.play("start_moving")
		else:
			print("Already there")
	else:
		print("currently moving")
	



func move_to_floor():
	if open_flag and not stopped:
		if going_up:
				path_follow_2d.progress +=2
		else:
			path_follow_2d.progress -=2
		pause()
	if automatic:
		up_or_down()
		

func begin_moving():
	stopped=false

func up_or_down():
	if snapped(path_follow_2d.progress_ratio,0.1)==0:
		going_up=true
	elif snapped(path_follow_2d.progress_ratio,0.1)==1.0:
		going_up=false
		
#Needs refactor########
func pause():
	if next_floor==snappedf(path_follow_2d.progress_ratio, 0.1):
		print("your floor sir")
		if going_up:
			animation_player.play("arrived_up")
		else:
			animation_player.play("arrived_down")
		stopped=true
		#pause_move.start(5)


func _on_resume_timeout() -> void:
	pass
	#print("opening menu")
	#animation_player.play("open_elevator_menu")


func _on_button_panel_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		panel_active=true

func _on_button_panel_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		panel_active=false
		close_elevator_menu()

func open_elevator_menu() -> void:
	if panel_active:
		animation_player.play("open_elevator_menu")
		elevator_ui.grab_focus()
		

func close_elevator_menu() -> void:
	animation_player.play("RESET")
