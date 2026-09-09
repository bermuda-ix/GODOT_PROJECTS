class_name ClashCounter extends LimboState

@export var actor : Node2D
@export var animation_player : AnimationPlayer
@export var state_machine : LimboHSM
#@export var anim_name : StringName = "clash_fail"

func _ready() -> void:
	animation_player.animation_finished.connect(counter_attack)

func _enter() -> void:
	animation_player.play()
	
func counter_attack() -> void:
	state_machine.dispatch(&"counter_attack")
	if "counter_clash" in actor:
		actor.counter_clash()
