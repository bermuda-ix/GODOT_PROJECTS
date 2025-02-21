extends Control

@onready var health_bar = $Health
@onready var state = $State
@onready var health_bar_ui = $HealthBar


var health = 3
var cur_state ="IDLE"
# Called when the node enters the scene tree for the first time.
func _ready():
	health=3
	cur_state="IDLE"
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	health_bar.text=str("Health: ", health)
	state.text=str("State: ", cur_state)

func set_health(value: int) -> void:
	health = value
	health_bar_ui.value=value
	
func set_cur_state(value: String) -> void:
	cur_state = value

func set_max_health(value: int) -> void:
	health_bar_ui.max_value = value
