class_name AttackStartState extends LimboState

@export var animation_player : AnimationPlayer
@export var attack_name : String
@export var pc : PlayerEntity = null

@onready var attack_debug := "Attack"

func  _ready() -> void:
	pc = get_tree().get_first_node_in_group("player")

func _enter() -> void:
	print_debug(attack_name)
	animation_player.play_section_with_markers(attack_name, "", "attack_start")
	print_debug(animation_player.current_animation)
	pc.attacking=true

func _exit() -> void:
	attack_debug=animation_player.current_animation
