extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_2d: Camera2D = $Background/Camera2D

@onready var dialogue_box: DialogueBoxController = $CanvasLayer/DialogueBox

@onready var cutscene_queue : PackedStringArray


func _ready() -> void:
	cutscene_queue=animation_player.get_animation_list()
	if cutscene_queue.has("RESET"):
		var _reset_index=cutscene_queue.find("RESET")
		cutscene_queue.remove_at(_reset_index)	
	print_debug(cutscene_queue)
	#animation_player.play()
	for i in cutscene_queue:
		if i==cutscene_queue[0]:
			animation_player.play(i)
		else:
			animation_player.queue(i)
	print_debug(animation_player.get_queue())
	

func _process(delta: float) -> void:
	if not animation_player.is_playing():
		if Input.is_action_just_pressed("attack")\
		 or Input.is_action_just_pressed("jump")\
		 or Input.is_action_just_pressed("Interact"):
			animation_player.play()
			#dialogue_box.hide_both()

func cutscene_wait_for_input() -> void:
	animation_player.pause()



func _on_dialogue_box_end_of_dialogue() -> void:
	#cutscene_wait_for_input()
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	pass
	#animation_player.pause()


func _on_animation_player_animation_changed(old_name: StringName, new_name: StringName) -> void:
	print_debug(old_name, " ", new_name)
