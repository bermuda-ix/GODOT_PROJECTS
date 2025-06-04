class_name CutsceneHandler
extends Node

@export var actor : Node2D
@export var anim_player : AnimationPlayer
@export var speech : Label
@onready var anim_count : int = 0
@onready var cutscene_dir : int = clampi(0, -1, 1) : set=set_cutscene_dir
@export var actor_control_active : bool = true : set=set_actor_control


func _ready() -> void:
	Events.start_cutscene.connect(start_cutscene)
	Events.end_cutsene.connect(end_cutscene)
	Events.queue_cutscene.connect(queue_cutscene)

func set_speech_text(value : String) -> void:
	speech.text=str(value)


func start_cutscene() -> void:
	set_actor_control(false)
	#anim_player.play(value)
	
func queue_cutscene(cutscenes : Array[String]) -> void:
	for cutscene in cutscenes:
		anim_player.queue(cutscene)
	
func end_cutscene() -> void:
	set_actor_control(true)
	anim_player.play("RESET")
	anim_count=0
	if actor.is_in_group("player"):
		actor.set_movement_data(0)
		anim_player.play("idle")

func anim_count_up() -> void:
	if not actor_control_active:
		anim_count+=1
	else:
		pass

func set_cutscene_dir(value : int) -> void:
	cutscene_dir=value

func set_actor_control(value : bool)->void:
	actor_control_active=value
