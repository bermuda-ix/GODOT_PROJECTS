class_name ClashHandler extends Node

@export var actor: Node2D
@export var animation_player : AnimationPlayer
@export var state_machine : LimboHSM
@export var hit_stop : HitStop
@export var stagger : Stagger
@export var desperate_attack_enabled := false

signal riposte_follow_up
signal riposte_heavy_follow_up
signal nothing_follow_up

func _ready() -> void:
	Events.parry_success.connect(clash_follow_up)

func clashed_helper() -> void:
	animation_player.stop()
	hit_stop.hit_stop(0.05, 0.5)
	print_debug("clashed!")
	match actor.atk_chain:
		"_1":
			pass
		"_2":
			pass
		"_3":
			pass
		"_counter":
			pass


func clash_follow_up(_follow_up := "nothing"):
	match _follow_up:
		"riposte":
			animation_player.play()
			actor.pushed_back(250)
			if desperate_attack_enabled and stagger.stagger==1:
				riposte_heavy_follow_up.emit()
			else:
				stagger.stagger-=1
				riposte_follow_up.emit()
			if stagger.stagger>0:
				state_machine.dispatch(&"hit")
			else:
				state_machine.dispatch(&"staggered")
		"nothing":
			nothing_follow_up.emit()
			actor.pushed_back(150)
			animation_player.play()
			nothing_follow_up.emit()
		_:
			animation_player.play()
