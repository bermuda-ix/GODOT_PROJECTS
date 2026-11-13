class_name AttackStartState extends LimboState

@export var animation_player : AnimationPlayer
@export var attack_name : String
@export var pc : PlayerEntity = null
@export var charge_timer : Timer = null
@export var hit_box_collision : CollisionShape2D

@onready var attack_debug := "Attack"

func  _ready() -> void:
	pc = get_tree().get_first_node_in_group("player")

func _enter() -> void:
	#hit_box_collision.set_deferred("disabled", false)
	print_debug(attack_name)
	animation_player.play_section_with_markers(attack_name, "", "attack_start")
	print_debug(animation_player.current_animation)
	pc.attacking=true
	charge_timer.start(0.2)

func _exit() -> void:
	hit_box_collision.set_deferred("disabled", false)
	attack_debug=animation_player.current_animation
