extends LimboState

@export var anim_player : AnimationPlayer
@export var hit_fx_player : AnimationPlayer
@export var hit_box : HitBox
@export var pc : PlayerEntity
@export var attack := "Attack"
@export var anim_second := 0.1


func _enter() -> void:
	pc.charging=true
	anim_player.play(attack)
	anim_player.pause()
	anim_player.seek(anim_second)

	hit_box.damage+=1
	hit_fx_player.play("charge_attack")

func _update(delta: float) -> void:
	pc.velocity=lerp(pc.velocity, Vector2.ZERO, 0.3)
	
func _exit() -> void:
	anim_player.play()
