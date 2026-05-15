extends LimboState

@export var actor : CharacterBody2D
@export var anim_player : AnimationPlayer
@export var attack_state : LimboHSM
@export var speed : float = 100.0
@onready var end_dash : bool = false
@onready var dur : Timer = Timer.new()
@onready var closing_dir : Vector2 = Vector2.RIGHT

signal dur_timeout

func _ready() -> void:
	add_child(dur)
	dur.autostart=false
	dur.one_shot=true
	dur.ignore_time_scale=false
	dur.timeout.connect(_on_dur_timeout)

func _enter() -> void:
	

	anim_player.play("Attack_Closer_Begin")
	dur.start(0.3)

func _update(delta: float) -> void:
	actor.velocity=closing_dir*speed
	if actor.velocity.x==0:
		print_debug("sum ting wong")
	if end_dash:
		attack_state.dispatch(&"dash_attack")
		

func _exit() -> void:
	actor.velocity.y=0
	end_dash=false



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="Attack_Closer_Begin":
		anim_player.play("Attack_Closer")


func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("hurtbox"):
		end_dash=true


func _on_dur_timeout() -> void:
	end_dash=true
