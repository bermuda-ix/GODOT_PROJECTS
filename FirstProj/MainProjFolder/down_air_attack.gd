extends LimboState

@export var anim_player : AnimationPlayer
@export var pc : PlayerEntity

func _enter() -> void:
	anim_player.speed_scale=1
	anim_player.play("down_attack")
	pc.hit_fx_player.speed_scale=1
	pc.hit_animation="hit_landed"
	pc.heavy_attack_flag=false
	#pc.attacking=true
