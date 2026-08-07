extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity
@export var attack := "Attack"
@export var attack_fx_sprite : AnimatedSprite2D

func _enter() -> void:
	anim_player.speed_scale=1
	anim_player.play(attack)
	pc.hit_fx_player.speed_scale=1
	pc.hit_animation="hit_landed"
	pc.heavy_attack_flag=false
	pc.attack_vfx(false)
	#attack_fx_sprite.animation="sword_hit_1"
	#pc.attacking=true

#func _update(delta: float) -> void:
	#assert(not Input.is_action_pressed("attack") and (not pc.charging))

func _exit() -> void:
	pass
