extends Control

@onready var health_bar = $Health
@onready var state = $State
@onready var health_bar_ui := $HealthBar
@onready var stagger_bar: TextureProgressBar = $StaggerBar
@onready var heat_fill_gauge: TextureProgressBar = $HeatFillGauge
@onready var heat_lvl_gauge: TextureProgressBar = $HeatLvlGauge

signal heat_lvl_raise

var health : int = 3
var cur_state ="IDLE"
var heat_lvl : int = 0: 
	set(value) : heat_lvl = clampi(value, 0, 7)
var heat_fill : int = 0:
	set(value) : heat_fill = clampi(value, 0, 9)
# Called when the node enters the scene tree for the first time.
func _ready():
	health=3
	cur_state="IDLE"
	Events.increase_heat_gauge.connect(increase_heat_gauge)
	Events.increase_heat_lvl.connect(increase_heat_lvl)
	Events.reset_heat.connect(reset_heat)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	set_heat_fill(heat_fill)
	set_heat_lvl(heat_lvl)


func set_health(value: int) -> void:
	health = value
	health_bar_ui.value=value
	
func set_cur_state(value: String) -> void:
	cur_state = value

func set_max_health(value: int) -> void:
	health_bar_ui.max_value = value

func set_stagger(value : int) -> void:
	stagger_bar.value=value
	
func set_max_stagger(value : int) -> void:
	stagger_bar.max_value=value


func set_heat_fill(value : int) -> void:
	heat_fill_gauge.value=value
	
func set_heat_lvl(value : int) -> void:
	heat_lvl_gauge.value=value
	
	if heat_lvl_gauge.value>=6:
		heat_lvl_raise.emit()


func increase_heat_gauge(value : int) -> void:
	heat_fill+=value
	GlobalSaveData.heat_stats["heat_gauge"]=heat_fill
	if heat_fill>=100:
		Events.increase_heat_lvl.emit(1)
	else:
		heat_fill_gauge.value=heat_fill
	
func increase_heat_lvl(value : int) -> void:
	heat_lvl+=value
	heat_lvl_gauge.value=heat_lvl

func reset_heat() -> void:
	heat_fill_gauge.value=0
	heat_lvl_gauge.value=0
