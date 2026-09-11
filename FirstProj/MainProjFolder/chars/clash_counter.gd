class_name ClashCounter extends LimboState

@export var actor : Node2D
@export var animation_player : AnimationPlayer
@export var state_machine : LimboHSM
@onready var signal_ready := false

func _ready() -> void:
	animation_player.animation_finished.connect(counter_attack)

func _enter() -> void:
	signal_ready=true
	animation_player.play()
	
	
func counter_attack(_anim_name : StringName) -> void:
	if not signal_ready:
		return
	state_machine.dispatch(&"counter_attack")
	if "counter_clash" in actor:
		actor.counter_clash()

func _exit() -> void:
	signal_ready=false
