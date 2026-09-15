class_name MoraleHandler extends Node

@export var actor : Node2D
@export var stagger : Stagger
@export var health : Health

@export var stagger_decrease_value := 1
@export var stagger_increase_value := 1
@export var low_stagger_threshold : int = 3
@export var low_morale_enabled := false
@export var navigation_handler : NavigationHandler
@export var on_screen : VisibleOnScreenNotifier2D
@export var active := false
signal low_stagger_morale
signal low_health_morale

func _ready() -> void:
	Events.enemy_death.connect(morale_decrease)
	#Events.enemy_parried.connect(morale_decrease)
	Events.enemy_staggered.connect(morale_decrease)
	Events.player_staggered.connect(morale_increase)
	Events.parry_failed.connect(morale_increase)


func morale_decrease() -> void:
	if not navigation_handler.path_valid() or not on_screen.is_on_screen():
		return
	if stagger.stagger<=0:
		return
	if health.health>0:
		stagger.stagger -= stagger_decrease_value
	
func morale_increase() -> void:
	if not navigation_handler.path_valid() or not on_screen.is_on_screen():
		return
	stagger.stagger += stagger_increase_value
	if stagger.stagger<low_stagger_threshold:
		low_morale_check()

func low_morale_check() -> void:
	if not low_health_morale:
		return
	else:
		low_stagger_morale.emit()
