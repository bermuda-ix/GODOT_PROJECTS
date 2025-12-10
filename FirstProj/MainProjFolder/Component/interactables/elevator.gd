extends Node2D

@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D
@onready var pause_move: Timer = $PauseMove
@onready var resume: Timer = $Resume
@onready var path_2d: Path2D = $Path2D

@onready var elevator_button = preload("res://Component/interactables/elevator_button.tscn")
@onready var elevator_ui: Control = $ElevatorUI
@onready var elevator_buttons: VBoxContainer = $ElevatorUI/PanelContainer/ScrollContainer/ElevatorButtons

@export var automatic : bool = false

#floors
@export_category("Floor Variables")
@onready var bottom_floor : float = 0
@export var top_floor : float =-400
@export var floors : Array[float]


#Stops based on progress_ratio
#@export var stops_ratio : Array[float]

var open_flag : bool = false
var stopped : bool = false
var going_up : bool = true

func _ready() -> void:
	path_2d.curve.set_point_out(1, Vector2(0,top_floor))
	#Push bottom floor and top floor into floors array as 0 and 1 ratio
	floors.push_front(0.0)
	floors.push_back(1.0)
	add_floor_buttons()
	
func _physics_process(delta: float) -> void:
	#print(snapped(path_follow_2d.progress_ratio, 0.1), " , ", going_up)
	
	if automatic:
		#pause()
		if open_flag and not stopped:
			if going_up:
				path_follow_2d.progress +=2
			else:
				path_follow_2d.progress -=2
				
			up_or_down()
			
		else:
			pass
	else:
		pass
		


func open():
	open_flag=true

func add_floor_buttons():
	
	print("This elevator has " + str(floors.size()) + " floors at:")
	for i in range(floors.size()):
		var _new_elevator_button = elevator_button.instantiate()
		_new_elevator_button.button_text = str(floors.size()-(i+1))
		_new_elevator_button.floor.connect(self.move_to_floor)
		_new_elevator_button.name = "Floor " + str(floors.size()-(i+1))
		print(_new_elevator_button.button_text)
		elevator_buttons.add_child(_new_elevator_button)
		

#for automaticallly moving elevators
func _on_pause_move_timeout() -> void:
	stopped=false
	resume.start(0.5)
	
func move_to_floor(_floor : int) -> void:
	print("Moving to floor ", _floor)


func up_or_down():
	if snapped(path_follow_2d.progress_ratio,0.1)==0:
		going_up=true
	elif snapped(path_follow_2d.progress_ratio,0.1)==1.0:
		going_up=false
		
#Needs refactor########
#func pause():
	#if stops_ratio.has(snapped(path_follow_2d.progress_ratio,0.1)) and pause_move.is_stopped() and resume.is_stopped():
		##print("your floor sir")
		#stopped=true
		#pause_move.start(5)
