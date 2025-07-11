extends LimboHSM

@export var actor : Node2D

func _ready() -> void:
	Events.parry_success.connect(counter)
	Events.parry_failed.connect(punish)

func _enter() -> void:
	#print("begin counter")
	actor.counter_timer.start()
	actor.hurt_box_collision.disabled=true
	actor.clash_mult+=1

func counter(value : String) -> void:
	#print(value)
	actor.counter_sm.dispatch(&"kick_counter")

func punish() -> void:
	actor.counter_sm.dispatch(&"counter_end")
	actor.clash_mult=1
