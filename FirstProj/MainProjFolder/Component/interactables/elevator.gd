extends Node2D

@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D
@onready var pause_move: Timer = $PauseMove
@onready var resume: Timer = $Resume
@onready var path_2d: Path2D = $Path2D

@export var top_floor : float =-400

#Stops based on progress_ratio
@export var stops_ratio : Array[float]

var open_flag : bool = false
var stopped : bool = false
var going_up : bool = true

func _ready() -> void:
	path_2d.curve.set_point_out(1, Vector2(0,top_floor))

func _physics_process(delta: float) -> void:
	#print(snapped(path_follow_2d.progress_ratio, 0.1), " , ", going_up)
	pause()
	if open_flag and not stopped:
		if going_up:
			path_follow_2d.progress +=2
		else:
			path_follow_2d.progress -=2
			
		up_or_down()
		
	else:
		pass

func up_or_down():
	if snapped(path_follow_2d.progress_ratio,0.1)==0:
		going_up=true
	elif snapped(path_follow_2d.progress_ratio,0.1)==1.0:
		going_up=false

func pause():
	if stops_ratio.has(snapped(path_follow_2d.progress_ratio,0.1)) and pause_move.is_stopped() and resume.is_stopped():
		#print("your floor sir")
		stopped=true
		pause_move.start(5)

func open():
	open_flag=true

func _on_pause_move_timeout() -> void:
	stopped=false
	resume.start(0.5)
