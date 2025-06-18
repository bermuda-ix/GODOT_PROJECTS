extends LimboHSM

@export var actor : Node2D

func _ready() -> void:
	Events.parry_success.connect(counter)

func _enter() -> void:
	print("begin counter")
	actor.hurt_box_collision.disabled=true
	actor.clash_multi+=1

func counter(value : String) -> void:
	print(value)
	actor.counter_sm.dispatch(&"kick_counter")
