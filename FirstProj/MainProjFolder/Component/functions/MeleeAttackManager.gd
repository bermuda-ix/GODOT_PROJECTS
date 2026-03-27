class_name MeleeAttackManager
extends Node

@export var actor : Node2D
@export var combo_max : int = 3
@onready var combo_int : int = clampi(1, 1, combo_max)
@onready var combo : String = "atk_"+str(combo_int)
@onready var atk_type := "atk_1"

func melee_attack():
	if actor.state_machine.get_active_state()==actor.attack:
		pass
	else:
		actor.state_machine.change_active_state(actor.attack)
		#"melee attack")
	actor.animation_player.play(combo)
	
func melee_counter():
	if actor.state_machine.get_active_state()==actor.attack:
		pass
	else:
		actor.state_machine.change_active_state(actor.attack)
		#print_debug("counter")
	actor.animation_player.play("atk_counter")
	reset_combo()

func next_combo() -> void:
	if combo_int==combo_max:
		combo_int=1
	else:
		combo_int+=1
	combo = "atk_"+str(combo_int)
	
func get_combo() -> String:
	return combo
	
func reset_combo() -> void:
	combo_int=0

func set_attack(_value : String) -> void:
	atk_type+_value

func atk_resume_helper() -> void:
	var _atk_type = get_combo().substr(4, -1)
	print_debug(_atk_type)
	if _atk_type=="_counter":
		actor.bt_player.blackboard.set_var("atk_counter", false)
		reset_combo()
		actor.bt_player.blackboard.set_var(get_combo(), true)
	else:
		next_combo()
		actor.bt_player.blackboard.set_var(get_combo(), true)
			
	actor.attack_timer.start(0.3)
	actor.bt_player.active=true
	actor.attacking=false

#func slam(value: String):
	##pass
	#var slam_type=value.capitalize()
	#match slam_type:
		#"DOWN":
			#actor.slam_vel+=actor.gravity+200

func slam():
	actor.slam_vel=actor.gravity+1000

func blast_attack():
	actor.animation_player.play("blast_attack")
