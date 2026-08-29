extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_2d: Camera2D = $Background/Camera2D

@onready var dialogue_box: DialogueBoxController = $CanvasLayer/DialogueBox

@onready var cutscene_queue : Array[String]

@onready var skippable : bool = true
var thread:= Thread.new()

func _ready() -> void:
	cutscene_queue.assign(animation_player.get_animation_list())
	if cutscene_queue.has("RESET"):
		var _reset_index=cutscene_queue.find("RESET")
		cutscene_queue.remove_at(_reset_index)	
	if cutscene_queue.has("END"):
		var _reset_index=cutscene_queue.find("END")
		cutscene_queue.remove_at(_reset_index)
	cutscene_queue.sort_custom(func(a, b): return int(a) < int(b))
	cutscene_queue.push_back(&"END")
	print_debug(cutscene_queue)
	
	###########################
	##Preload adventure level##
	###########################
	
	###uncomment of exe build
	#thread.start(load_next_levels)
	
	Global.game_controller._init_objectives(ObjectivesByLevel.prologue_init_objectives)
	
	###########################
	
	#animation_player.play()
	for i in cutscene_queue:
		if i==cutscene_queue[0]:
			animation_player.play(i)
		else:
			animation_player.queue(i)
	print_debug(animation_player.get_queue())
	

func _process(delta: float) -> void:
			
	if (Input.is_action_just_pressed("attack")\
	 or Input.is_action_just_pressed("jump")\
	 or Input.is_action_just_pressed("Interact")):
		if (dialogue_box.playing_bot or dialogue_box.playing_top):
			if skippable:
				animation_player.stop(true)
				dialogue_box.skip_to_end()
			else:
				pass
		elif not animation_player.is_playing():
			cutscene_queue.remove_at(0)
			if cutscene_queue.is_empty():
				print("end of scene")
			else:
				animation_player.play(cutscene_queue[0])
		else:
			pass
			
			
	
func cutscene_wait_for_input() -> void:
	animation_player.pause()

func toggle_skip(value : bool) -> void:
	skippable=value

func end_cutscene(_next_scene : String = "PrologueLvl") -> void:
	Global.game_controller.change_2d_scene("PrologueLvl", true, false, -1, "fade_to_black_quick", "fade_from_black_quick")

func load_next_levels():
	Global.game_controller.load_levels(LevelsList.prologue_unique_levels)
	Global.game_controller.load_levels(LevelsList.level_maps)
	thread.call_deferred("wait_to_finish")
	print_debug("next levels loaded")

func _on_dialogue_box_end_of_dialogue() -> void:
	#cutscene_wait_for_input()
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass
	#animation_player.pause()


func _on_animation_player_animation_changed(old_name: StringName, new_name: StringName) -> void:
	print_debug(old_name, " ", new_name)
