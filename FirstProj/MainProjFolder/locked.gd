extends LimboState

@export var pc : PlayerEntity

func _enter() -> void:
	print_debug("locking on")
	
#func _update(delta: float) -> void:
	#pc.label.text=str(self.name)
