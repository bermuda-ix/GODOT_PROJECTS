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
@onready var global_flag_handler: GlobalFlagHandler = $GlobalFlagHandler
@onready var door_collision: CollisionShape2D = $Path2D/PathFollow2D/StaticBody2D/Door/DoorCollision



@export_category("Global Flag Variable")
@export var global_flag : String
@export var flag_active : bool = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_player_door: AnimationPlayer = $AnimationPlayerDoor
@export_category("Elevator Variables")
@export var active : bool = true
@export var automatic : bool = false
@export var speed : int = 1

#floors
@export_category("Floor Variables")
@onready var bottom_floor : float = 0
@onready var current_floor : float = 0.0
@onready var next_floor : float = 0.0
@export var top_floor : float =-400
@export var floors : Array[float]
@export var init_floor : int = 0
@export var locked_floors : Array[int] = [0.0, 1.0]


#Stops based on progress_ratio
#@export var stops_ratio : Array[float]

var open_flag : bool = true
var stopped : bool = true
var going_up : bool = true

func _ready() -> void:
	path_2d.curve.set_point_out(1, Vector2(0,top_floor))

	add_floor_buttons()
	current_floor=floors[init_floor]
	path_follow_2d.progress_ratio=current_floor
	resume.start(3)
	global_flag_handler.flag_name=global_flag
	global_flag_handler.flag_active=flag_active
	Events.open_interact_menu.connect(open_elevator_menu)
	#Events.checkpoint_reached.connect(save_state)
	
func _physics_process(delta: float) -> void:
	#print_debug(snapped(path_follow_2d.progress_ratio, 0.1), " , ", going_up)
	move_to_floor()

	
		


func open():
	open_flag=true

func add_floor_buttons():
	
	print_debug("This elevator has " + str(floors.size()) + " floors at:")
	for i in range(floors.size()):
		var _new_elevator_button = elevator_button.instantiate()
		_new_elevator_button.button_text = str(floors.size()-(i+1))
		if locked_floors.has(floors.size()-(i+1)):
			_new_elevator_button.toggle_floor_lock(true)
		_new_elevator_button.floor.connect(self.choose_floor)
		_new_elevator_button.name = "Floor " + str(floors.size()-(i+1))
		print_debug(_new_elevator_button.button_text)
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
			print_debug("Moving up to floor ", _floor)
			going_up=true
			animation_player.play("start_moving")
			animation_player_door.play("close")
		elif current_floor>next_floor:
			print_debug("Going down to floor ", _floor)
			going_up=false
			animation_player.play("start_moving")
			animation_player_door.play("close")
		else:
			print_debug("Already there")
	else:
		print_debug("currently moving")
	



func move_to_floor():
	if open_flag and not stopped:
		if going_up:
				path_follow_2d.progress +=speed
		else:
			path_follow_2d.progress -=speed
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
		
func pause():
	if next_floor==path_follow_2d.progress_ratio:
		print_debug("your floor sir")
		if going_up:
			animation_player.play("arrived_up")
			animation_player_door.play("open")
		else:
			animation_player.play("arrived_down")
			animation_player_door.play("open")
		stopped=true
		#pause_move.start(5)

#func save_state():
	#var _name=self.get_path()
	#GlobalSaveData.add_persistent_value(_name, str(active))
	#
#func load_state(value : String):
	#if value=="true":
		#active=true
	#else:
		#active=false

func _on_resume_timeout() -> void:
	pass
	#print_debug("opening menu")
	#animation_player.play("open_elevator_menu")


func _on_button_panel_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		panel_active=true

func _on_button_panel_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		panel_active=false
		elevator_ui.visible=false
		Events.close_interact_menu.emit()

func open_elevator_menu() -> void:
	if panel_active:
		animation_player.play("open_elevator_menu")
		elevator_ui.grab_focus()
		

#func close_elevator_menu() -> void:
	#animation_player.play("RESET")


func _on_player_detect_body_entered(body: Node2D) -> void:
	if not active:
		return
	else:
		if body.is_in_group("player"):
			animation_player_door.play("open")


func _on_player_detect_body_exited(body: Node2D) -> void:
	if not active:
		return
	else:
		if body.is_in_group("player"):
			animation_player_door.play("close")


func _on_global_flag_handler_flag_activate() -> void:
	active=true

#Persistant Helper Functions
func get_state() -> String:
	return str(active)

func _on_persistant_state_handler_update_state(value: String) -> void:
	if value == "true":
		active=true
	else:
		active=false
