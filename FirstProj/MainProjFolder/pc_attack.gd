extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity
@onready var attack_state: LimboHSM = $"."


func _enter() -> void:
	print("entering attack")
#
func _exit() -> void:
	pc.attack_timer.paused=false
	#print("exit attack")
