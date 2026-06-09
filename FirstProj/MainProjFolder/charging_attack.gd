extends LimboState

@export var anim_player : AnimationPlayer
@export var vfx_player : AnimationPlayer
@export var hit_box : HitBox
@export var pc : PlayerEntity
@export var attack := "Attack"


func _enter() -> void:
	anim_player.play(attack)
	anim_player.pause()
	hit_box.heavy_attack=true
	
func _exit() -> void:
	anim_player.play()
