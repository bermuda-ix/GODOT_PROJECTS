#############################################
# Class Name: Despawn Handler				
# Purpose: To despawn object while			
#	while on screen with effects			
# Exported Variables: actor -> Root Scene
#	animation_player -> Animation Player of root scene
#	despawn_effect -> PackedScene Visual/Sound effects for despawning
#	timer_sec -> Despawn time between function called and function ending
#############################################

class_name DespawnHandler

extends Node

@export var actor : Node2D
@export var despawn_effect : PackedScene
@export var timer_sec : float

func despawn():
	var despawn_effect_inst=despawn_effect.instantiate()
	despawn_effect_inst.global_position=Vector2(actor.global_position.x, actor.global_position.y)
	await get_tree().create_timer(timer_sec).timeout 
	get_tree().current_scene.add_child(despawn_effect_inst)
	await get_tree().create_timer(0.1).timeout 
	actor.queue_free()
