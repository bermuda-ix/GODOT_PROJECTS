extends LimboState

@export var pc : PlayerEntity

func _enter() -> void:
	pc.knockback.x=20*pc.face_dir
