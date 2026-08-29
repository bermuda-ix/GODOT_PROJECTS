class_name clash_followup_handler extends Node

@export var actor : Node2D
@export var animation_player : AnimationPlayer
@export var stagger : Stagger
@export var state_machine : LimboHSM

@export_category("clash_behavior")
@export var counter_enable : bool = false
@export var heavy_counter_enable : bool = false
@export var desperate_counter_enable : bool = false

func clash_follow_up(_follow_up := "nothing"):
	match _follow_up:
		"riposte":
			animation_player.play()
			if "push_back" in actor:
				actor.pushed_back(200)
			if stagger.stagger==1 and desperate_counter_enable:
				pass
				print_debug("state machine transition to heavy attack here")
			else:
				stagger.stagger-=1
				if stagger.stagger>0:
					state_machine.dispatch(&"hit")
				else:
					state_machine.dispatch(&"staggered")
		"nothing":
			if actor.player_right:
				actor.knockback.x=-250
			else:
				actor.knockback.x=250
			animation_player.play()
		_:
			animation_player.play()
