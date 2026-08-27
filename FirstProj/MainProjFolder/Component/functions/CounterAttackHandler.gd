class_name CounterAttackHandler
extends Node

@export var actor : Node2D
@export var jump_handler : JumpHandler
@export var shoot_attack_manager : ShootAttackManager
@export var state_machine : LimboHSM
@export var bt_player : BTPlayer
@export var counter_attack_timer : Timer
@export var hit_stop : HitStop

@export var shoot_counter_active : bool = true
@export var active : bool = true

func _ready() -> void:
	Events.parry_success.connect(parry_counter)
	counter_attack_timer.timeout.connect(clash_counter)

func _physics_process(delta: float) -> void:
	if not active:
		return
	
	if shoot_counter_active:
		shoot_counter()
				
	if actor.player_state == actor.player.flip_state:
		if actor.player_right:
			actor.scale.x = -1
		else:
			actor.scale.x = 1
		#bt_player.blackboard.set_var("counter_attack", true)
		
	else:
		pass
		#bt_player.blackboard.set_var("counter_attack", false)
		
func shoot_counter():
	if actor.player_state == actor.player.special_attack:
		if state_machine.get_active_state()!=actor.attack:
			if actor.player_state == actor.player.flip_state:
				shoot_attack_manager.shoot()
			else:
				#handle_jump(0.5)
				
				if state_machine.get_active_state()==actor.attack:
					state_machine.dispatch(&"jump")

func parry_counter(value: String) -> void:
	if actor.parried:
		#if actor.stagger.stagger>=0:
			#print_debug(value)
			#
		#else:
			#pass
		actor.parried=false
			

func clash_counter()-> void:
	hit_stop.end_hit_stop()
	state_machine.dispatch(&"counter_melee")
	Events.parry_success.emit("enemy_light_counter")
