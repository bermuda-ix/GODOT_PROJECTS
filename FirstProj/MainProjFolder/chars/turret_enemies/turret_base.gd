class_name TurretBase
extends StaticBody2D

@onready var collision_shape_2d: CollisionShape2D = $Size/CollisionShape2D
@onready var target_lock_node: TargetLock = $TargetLock
@onready var on_screen: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var death_handler: DeathHandler = $DeathHandler
@onready var turret_top: Node2D = $turret_top
@onready var despawn_handler: DespawnHandler = $DespawnHandler
@onready var hurt_box: HurtBox = $HurtBox
@onready var hurt_box_collision: CollisionPolygon2D = $HurtBox/HurtBoxCollision
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var hit_stop: HitStop = $HitStop

@onready var state_machine: LimboHSM = $StateMachine
@onready var death: LimboState = $StateMachine/Death
@onready var alive: LimboState = $StateMachine/Alive

@onready var death_sparks1: GPUParticles2D = $AnimatedSprite2D/GPUParticles2D
@onready var death_sparks2: GPUParticles2D = $AnimatedSprite2D/GPUParticles2D2
@onready var death_sparks3: GPUParticles2D = $AnimatedSprite2D/GPUParticles2D3


@onready var npc_stats: Control = $NPCStats
@onready var health: Health = $Health
@onready var stagger: Stagger = $Stagger

@onready var ammo_count

@onready var linked_turrets : Array[TurretBase]

@export var turret_link_control : TurretLink
@onready var turret_link_order : int

signal turret_death

func _ready() -> void:
	_init_state_machine()
	ammo_count=turret_top.turret.ammo_count
	turret_top.health.set_max_health(health.get_max_health())
	if turret_link_control == null:
		print_debug("no link")
		if linked_turrets.size()<=1:
			print_debug("no link")
	else:
		linked_turrets=turret_link_control.turrets
		for i in range(linked_turrets.size()):
			print_debug(linked_turrets[i].name, " linked")
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
	#turret_top.death_handler.death()
	turret_top.bt_player.active=false
	turret_top.animation_player.play("death")
	state_machine.dispatch(&"die")
	death_handler.death()
	death_sparks1.emitting=true
	death_sparks2.emitting=true
	death_sparks3.emitting=true
	linked_turrets.remove_at(turret_link_order)
	print_debug("despawning")
	despawn_handler.despawn()
	turret_death.emit()

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


func _on_turret_top_shoot() -> void:
	animation_player.play("Firing")


func _on_turret_top_health_change(_new_health: int) -> void:
	health.set_health(_new_health)
