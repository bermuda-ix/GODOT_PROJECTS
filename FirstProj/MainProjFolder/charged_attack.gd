extends LimboState

@export var hit_box : HitBox

func _enter() -> void:
	print_debug("finished charge")
	hit_box.knock_back=true
	hit_box.knock_back_strength=100

func _exit() -> void:
	hit_box.heavy_attack=false
	hit_box.knock_back=false
