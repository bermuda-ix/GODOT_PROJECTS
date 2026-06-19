class_name CeilingLights extends PointLight2D

@export var flicker_active : bool = true
@export var flicker_delay : int = 5
@export var relight_delay : float = 0.1
@onready var flicker_timer := Timer.new()
@onready var shut_off_flag: GlobalFlagHandler = $ShutOffFlag
@onready var flicker_on_player_flag: GlobalFlagHandler = $FlickerOnPlayerFlag
@onready var persistent_data_handler: PersistentDataHandler = $PersistentDataHandler
@onready var persistent_data_handler3: PersistentDataHandler = $FlickerOnPlayerFlag/PersistentDataHandler



func _ready() -> void:
	add_child(flicker_timer)
	flicker_timer.one_shot=true
	flicker_timer.autostart=false
	flicker_timer.timeout.connect(_on_timer_timeout)

func _physics_process(delta: float) -> void:
	if flicker_active:
		flicker()
		

func flicker() -> void:
	var _flicker : int = randi_range(0, 100)
	var _relight : float = randf_range(0.1,relight_delay)
	if energy>0:
		if _flicker < flicker_delay:
			energy=0
			flicker_timer.start(_relight)

func _on_timer_timeout() -> void:
	energy=3


func _on_area_2d_body_entered(body: Node2D) -> void:
	if flicker_on_player_flag.flag_active:
		enabled=true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if flicker_on_player_flag.flag_active:
		enabled=false


func _on_shut_off_flag_flag_activate() -> void:
	flicker_on_player_flag.flag_active=true
	enabled=false


func _on_persistent_data_handler_data_loaded(value: String) -> void:
	if value == "true":
		enabled=true
	else:
		enabled=true


func _on_persistent_data_handler_flicker_data_loaded(value: String) -> void:
	if value == "true":
		flicker_active=true
	else:
		flicker_active=true


func _on_persistent_data_handler_flicker_on_player_data_loaded(value: String) -> void:
	if value == "true":
		flicker_on_player_flag.flag_active=true
	else:
		flicker_on_player_flag.flag_active=true
