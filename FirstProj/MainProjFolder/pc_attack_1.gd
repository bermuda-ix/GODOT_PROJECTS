extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity
@export var attack := "Attack"

func _enter() -> void:
	anim_player.speed_scale=1
	anim_player.play(attack)
	pc.hit_fx_player.speed_scale=1
	pc.hit_animation="hit_landed"
	pc.heavy_attack_flag=false
	#pc.attacking=true

func _update(delta: float) -> void:
	assert(not Input.is_action_pressed("special_attack"))

func _exit() -> void:
	pass
