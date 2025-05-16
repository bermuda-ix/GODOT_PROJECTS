extends Area2D

@onready var player : PlayerEntity
@onready var qte_active : bool = true
@export var first_qte_anim : String
@export var cutscene_player : AnimationPlayer

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and qte_active==true:
		print("begint the QTE")
		qte_active=false
		cutscene_player.play(first_qte_anim)
		Events.start_cutscene.emit()
