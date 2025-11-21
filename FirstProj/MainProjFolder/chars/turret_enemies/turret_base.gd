class_name TurretBase
extends StaticBody2D

@onready var collision_shape_2d: CollisionShape2D = $Size/CollisionShape2D
@onready var target_lock_node: TargetLock = $TargetLock
@onready var on_screen: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var death_handler: DeathHandler = $DeathHandler
@onready var turret_top: TurretTop = $turret_top
@onready var despawn_handler: DespawnHandler = $DespawnHandler
@onready var hurt_box: HurtBox = $HurtBox
@onready var hurt_box_collision: CollisionPolygon2D = $HurtBox/HurtBoxCollision

@onready var hit_stop: HitStop = $HitStop

@onready var state_machine: LimboHSM = $StateMachine
@onready var death: LimboState = $StateMachine/Death
@onready var alive: LimboState = $StateMachine/Alive

@onready var npc_stats: Control = $NPCStats
@onready var health: Health = $Health
@onready var stagger: Stagger = $Stagger

@onready var ammo_count

@onready var linked_turrets : Array[TurretBase]

@export var turret_link_control : TurretLink
@onready var turret_link_order : int

func _ready() -> void:
	_init_state_machine()
	ammo_count=turret_top.turret.ammo_count
	turret_top.health.set_max_health(health.get_max_health())
	if turret_link_control == null:
		print("no link")
		if linked_turrets.size()<=1:
			print("no link")
	else:
		linked_turrets=turret_link_control.turrets
		for i in range(linked_turrets.size()):
			print(linked_turrets[i].name, " linked")
			turret_link_order=linked_turrets.find(self)

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
	return abs(collision_shape_2d.get_shape().size.x * scale.x)
func get_height() -> int:
	return abs(collision_shape_2d.get_shape().size.y * scale.y)

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
	linked_turrets.remove_at(turret_link_order)
	print("despawning")
	despawn_handler.despawn()

func _on_hurt_box_received_damage(damage: int) -> void:
	hit_stop.hit_stop(0.05,0.1)


func _on_stagger_staggered() -> void:
	turret_top.staggered()
	hurt_box.set_damage_mulitplyer(3)


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("sp_atk_default"):
		stagger.stagger -= 1
		if turret_top.state_machine.get_active_state()==turret_top.stagger:
			health.health-=1

func stagger_recover()->void:
	stagger.stagger=stagger.max_stagger
	hurt_box.set_damage_mulitplyer(1)
