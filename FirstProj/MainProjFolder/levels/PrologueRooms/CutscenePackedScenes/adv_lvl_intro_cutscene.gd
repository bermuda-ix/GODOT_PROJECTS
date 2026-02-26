extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_2d: Camera2D = $Camera2D
@onready var dialogue_box: DialogueBoxController = $CanvasLayer/DialogueBox

@onready var cutscene_queue : PackedStringArray


func _ready() -> void:
	animation_player.play("Begin")
	cutscene_queue=animation_player.get_animation_list()
	print(cutscene_queue)

func _process(delta: float) -> void:
	if not animation_player.is_playing():
		if Input.is_action_just_pressed("attack")\
		 or Input.is_action_just_pressed("jump")\
		 or Input.is_action_just_pressed("Interact"):
			animation_player.play()
			dialogue_box.hide_both()

func cutscene_wait_for_input() -> void:
	animation_player.pause()



func _on_dialogue_box_end_of_dialogue() -> void:
	cutscene_wait_for_input()
