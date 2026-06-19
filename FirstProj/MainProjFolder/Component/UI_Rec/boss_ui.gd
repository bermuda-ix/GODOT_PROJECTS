extends Control

const HEALTH_BAR_SPEED := 10.0
const STAMINA_BAR_SPEED := 20.0

@export var health: Health
@export var stagger: Stagger
@export var actor : Node2D

@onready var boss_health: TextureProgressBar = $BossHealth
@onready var boss_stamina: TextureProgressBar = $BossStamina
#
#@export_category("debuging values")
#@export var health_debug := 100.0
#@export var stagger_debug := 10


var cur_state ="IDLE"
var heat_lvl : int = 0: 
	set(value) : heat_lvl = clampi(value, 0, 6)
var heat_fill : int = 0:
	set(value) : heat_fill = clampi(value, 0, 9)
# Called when the node enters the scene tree for the first time.
func _ready():

	set_max_boss_health(health.max_health)
	set_max_boss_stamina(stagger.max_stagger)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_boss_health_smooth(health.health, delta)
	set_boss_stagger_smooth(stagger.stagger, delta)


func set_boss_health(value: int) -> void:
	boss_health.value=value
	
func set_boss_health_smooth(value: int, delta: float) -> void:
	var _weight = abs(1.0-exp(HEALTH_BAR_SPEED*delta))
	boss_health.value=lerpf(boss_health.value, value, _weight)
	
func set_max_boss_health(value: int) -> void:
	boss_health.max_value = value



func set_boss_stagger(value: int) -> void:
	boss_stamina.value=value
	
func set_boss_stagger_smooth(value: int, delta: float) -> void:
	var _weight = abs(1.0-exp(STAMINA_BAR_SPEED*delta))
	boss_stamina.value=lerpf(boss_stamina.value, value, _weight)
	
func set_max_boss_stamina(value: int) -> void:
	boss_stamina.max_value = value


func activate_boss_ui() -> void:
	boss_health.visible=true
	boss_stamina.visible=true
	
func activate_mini_boss_ui() -> void:
	boss_stamina.visible=true
	
func deactivate_boss_ui() -> void:
	boss_health.visible=false
	boss_stamina.visible=false
	
func deactivate_mini_boss_ui() -> void:
	boss_stamina.visible=false
