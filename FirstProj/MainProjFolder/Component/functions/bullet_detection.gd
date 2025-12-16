class_name BulletDetection extends Area2D

signal bullet_detected

func _ready() -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	bullet_detected.emit()


func _on_body_entered(body: Node2D) -> void:
	bullet_detected.emit()
