extends LimboState

@export var hit_box : HitBox
@export var pc : PlayerEntity
@export var clash_power : ClashPower

func _enter() -> void:
	print_debug("finished charge")
	hit_box.knock_back=true
	hit_box.knock_back_strength=100
	if Input.is_action_pressed("attack"):
		pc.charging=true
		

func _exit() -> void:
	hit_box.heavy_attack=false
	hit_box.knock_back=false
	clash_power.reset_clash()
