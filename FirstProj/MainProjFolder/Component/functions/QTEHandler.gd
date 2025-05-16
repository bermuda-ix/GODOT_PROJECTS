class_name QTEHandler
extends Node

@export var actor : Node2D
@export var anim_player : AnimationPlayer
@export var speech : Label
@onready var anim_count : int = 0
@onready var cutscene_dir : int = clampi(0, -1, 1) : set=set_cutscene_dir
@export var actor_control_active : bool = true : set=set_actor_control
@export var await_player_input : bool = false : set=set_qte_begin
@export var QTE_begin : bool = false : set=set_qte_begin
@export var qte_pause : HitStop




func set_speech_text(value : String) -> void:
	speech.text=str(value)
	

func start_qte(value : int) -> void:
	set_actor_control(false)
	set_qte_begin(true)
	qte_pause.hit_stop(0.05, value)
	#anim_player.play(value)
	
func queue_qte(cutscenes : Array[String]) -> void:
	pass
	
func end_qte() -> void:
	set_actor_control(true)
	anim_player.play("RESET")
	anim_count=0
	actor.set_movement_data(0)

func set_cutscene_dir(value : int) -> void:
	cutscene_dir=value

func set_actor_control(value : bool)->void:
	actor_control_active=value

func set_qte_begin(value : bool)->void:
	await_player_input=value
