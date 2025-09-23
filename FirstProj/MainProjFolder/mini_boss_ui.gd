extends Control

@export var health: Health
@export var stagger: Stagger
@export var actor : Node2D

@onready var boss_health: TextureProgressBar = $MiniBossHealth
@onready var boss_stamina: TextureProgressBar = $BossStamina




var cur_state ="IDLE"
var heat_lvl : int = 0: 
	set(value) : heat_lvl = clampi(value, 0, 6)
var heat_fill : int = 0:
	set(value) : heat_fill = clampi(value, 0, 9)
# Called when the node enters the scene tree for the first time.
func _ready():

	cur_state="IDLE"
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_mini_boss_health(health.health)
	set_boss_stagger(stagger.stagger)




func set_mini_boss_health(value: int) -> void:

	mini_boss_health.value=value
	
func set_max_mini_boss_health(value: int) -> void:
	mini_boss_health.max_value = value

func set_boss_stagger(value: int) -> void:

	boss_stamina.value=value
	
func set_max_boss_stamina(value: int) -> void:
	boss_stamina.max_value = value


func activate_boss_ui() -> void:
	boss_stamina.visible=true
	
func activate_mini_boss_ui() -> void:
	mini_boss_health.visible=true
	boss_stamina.visible=true
	
func deactivate_boss_ui() -> void:
	boss_stamina.visible=false
	
func deactivate_mini_boss_ui() -> void:
	mini_boss_health.visible=false
	boss_stamina.visible=false
