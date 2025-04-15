extends Control

@export var health: Health
@export var stagger: Stagger
@export var actor : Node2D

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var stagger_bar: TextureProgressBar = $StaggerBar
@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var ammo_count: RichTextLabel = $RichTextLabel/AmmoCount

var has_ammo : bool = true

func _ready() -> void:
	set_max_health(health.get_max_health())
	set_max_stagger(stagger.get_max_stagger())
	#set_ammo(actor.turret_top.turret.ammo_count)
	
func _process(delta: float) -> void:
	set_health(health.health)
	set_stagger(stagger.stagger)
	set_ammo(actor.ammo_count)

func set_health(value: int) -> void:
	health_bar.value=value
	
func set_max_health(value: int) -> void:
	health_bar.max_value = value
	
func set_stagger(value: int) -> void:
	stagger_bar.value=value

func set_max_stagger(value: int) -> void:
	stagger_bar.max_value=value
	
func set_ammo(value: int) -> void:
	ammo_count.text=str(value)
