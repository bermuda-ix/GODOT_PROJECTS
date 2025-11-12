extends Node2D

@onready var hurt_box: HurtBox = $HurtBox
@onready var stagger: Stagger = $Stagger
@onready var health: Health = $Health
@onready var label: Label = $Label

func _process(delta: float) -> void:
	label.text="H: " + str(health.health) + " S: " + str(stagger.stagger)



func _on_hurt_box_received_damage(damage: int) -> void:
	pass # Replace with function body.

func _on_hurt_box_received_stagger_damage(damage: int) -> void:
	pass # Replace with function body.
