class_name TurretBase
extends StaticBody2D

@onready var collision_shape_2d: CollisionShape2D = $Size/CollisionShape2D
@onready var target_lock_node: TargetLock = $TargetLock
@onready var on_screen: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var death_handler: DeathHandler = $DeathHandler
@onready var turret_top: TurretTop = $turret_top
@onready var despawn_handler: DespawnHandler = $DespawnHandler

@onready var hit_stop: HitStop = $HitStop

@onready var state_machine: LimboHSM = $StateMachine
@onready var death: LimboState = $StateMachine/Death
@onready var alive: LimboState = $StateMachine/Alive

@onready var npc_stats: Control = $NPCStats
@onready var health: Health = $Health
@onready var stagger: Stagger = $Stagger

@onready var ammo_count


func _ready() -> void:
	_init_state_machine()
	ammo_count=turret_top.turret.ammo_count

func _process(delta: float) -> void:
	ammo_count=turret_top.turret.ammo_count
	if turret_top.state_machine.get_active_state()==turret_top.idle:
		npc_stats.visible=false
	else:
		npc_stats.visible=true
		
	
func _init_state_machine():
	state_machine.initial_state=alive
	state_machine.initialize(self)
	state_machine.set_active(true)
	
	state_machine.add_transition(alive, death, &"die")

func dying():
	pass
	
func get_width() -> int:
	return collision_shape_2d.get_shape().size.x * scale.x
func get_height() -> int:
	return collision_shape_2d.get_shape().size.y * scale.y

func target_lock():
	Events.unlock_from.emit()
	target_lock_node.target_lock()
	


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	pass # Replace with function body.


func _on_health_health_depleted() -> void:
	state_machine.dispatch(&"death")
	death_handler.death()
	turret_top.death_handler.death()
	turret_top.bt_player.restart()
	print("despawning")
	despawn_handler.despawn()

func _on_hurt_box_received_damage(damage: int) -> void:
	hit_stop.hit_stop(0.05,0.1)
