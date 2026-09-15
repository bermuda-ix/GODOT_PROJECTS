extends LimboState

@export var player : PlayerEntity
@export var anim_player : AnimationPlayer
@export var knockback_recovery_timer : Timer
@export var recover_timer := 3.0

func _enter() -> void:
	#anim_player.stop()
	player.input_active = false
	anim_player.play("enemy_countered")
	player.velocity=Vector2.ZERO

func _update(delta: float) -> void:
	player.move_and_slide()
	player.label.text=str(player.knockback)
	
func _exit() -> void:
	player.input_active = true
