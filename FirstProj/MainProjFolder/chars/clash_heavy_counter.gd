class_name ClashHeavyCounterState extends LimboState

@export var actor: Node2D
@export var animation_player: AnimationPlayer
@export var counter_anim := &"heavy_counter"
@onready var player : PlayerEntity = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _enter() -> void:
	player.state_machine.dispatch(&"got_countered")
	animation_player.play(counter_anim)
