extends Node2D

@onready var bomb: AnimatedSprite2D = $AnimatedSprite2D/Bomb
@onready var bomb_active : bool = false
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var bomb_timer: Timer = $BombTimer


func _ready() -> void:
	animation_player.play("idle")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("up"):
		activate_explosive()

func activate_explosive() -> void:
	if not bomb_active:
		bomb.visible=true
		bomb.play("Active")
		bomb_active=true
		bomb_timer.start()

func explode() -> void:
	animation_player.play("explode")


func _on_bomb_timer_timeout() -> void:
	explode()
