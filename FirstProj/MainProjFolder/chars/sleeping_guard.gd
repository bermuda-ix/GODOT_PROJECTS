class_name IdleEnemy
extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var health: Health = $Health
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurt_box: HurtBox = $HurtBox
@onready var hurt_box_collision: CollisionShape2D = $HurtBox/hurt_box_collision
@onready var target_lock_node: TargetLock = $TargetLock

var player : PlayerEntity = null

@onready var state_machine: LimboHSM = $LimboHSM
@onready var death: LimboState = $LimboHSM/Death
@onready var idle: LimboState = $LimboHSM/Idle
@onready var dying: BTState = $LimboHSM/Dying

@onready var death_handler: DeathHandler = $DeathHandler

@onready var bt_player: BTPlayer = $BTPlayer

@onready var on_screen: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready():
	player = get_tree().get_first_node_in_group("player")
	#set_state(current_state, States.CHASE)
	animation_player.play("idle")
	_init_state_machine()

func _process(delta: float) -> void:
	if on_screen.is_on_screen():
		print("on screen")

func _init_state_machine():
	state_machine.initial_state=idle
	state_machine.initialize(self)
	state_machine.set_active(true)

	state_machine.add_transition(state_machine.ANYSTATE, dying, &"die")
	state_machine.add_transition(dying, death, dying.success_event)

func target_lock():
	Events.unlock_from.emit()
	target_lock_node.target_lock()

func get_width() -> int:
	return collision_shape_2d.get_shape().radius
func get_height() -> int:
	return collision_shape_2d.get_shape().radius+10


func _on_hurt_box_received_damage(damage: int) -> void:
	pass # Replace with function body.


func _on_health_health_depleted() -> void:
	death_handler.death()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if state_machine.get_active_state()==death:
		queue_free()
