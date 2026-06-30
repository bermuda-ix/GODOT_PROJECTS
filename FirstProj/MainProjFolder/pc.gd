extends CharacterBody2D
class_name PlayerEntity

static var player: PlayerEntity = null

const hit1 = "res://Art_Components/Effects/sound/Socapex - Evol Online SFX - Punches and hits/Socapex - Evol Online SFX - Punches and hits/Socapex - Swordsmall_1.wav"
const hit2 = "res://Art_Components/Effects/sound/Socapex - Evol Online SFX - Punches and hits/Socapex - Evol Online SFX - Punches and hits/Socapex - Swordsmall_2.wav"
const hit3 = "res://Art_Components/Effects/sound/Socapex - Evol Online SFX - Punches and hits/Socapex - Evol Online SFX - Punches and hits/Socapex - Swordsmall_3.wav"

const swing1 = "res://Art_Components/Effects/sound/swishes/swishes/swish-1.wav"
const swing2 = "res://Art_Components/Effects/sound/swishes/swishes/swish-3.wav"
const swing3 = "res://Art_Components/Effects/sound/swishes/swishes/swish-5.wav"
const parry_sfx = "res://Art_Components/Effects/sound/Socapex - Evol Online SFX - Punches and hits/Socapex - Evol Online SFX - Punches and hits/Socapex - big punch.wav"
const shotgun_fire = "res://Art_Components/Effects/sound/mike_koenig-shotgun/mike_koenig-shotgun/10 Guage Shotgun-SoundBible.com-74120584.wav"
const reload = "res://Art_Components/Effects/sound/mike_koenig-shotgun/mike_koenig-shotgun/Chambering A Round-SoundBible.com-854171848.wav"


const CLOCKWISE=PI/2
const COUNTER_CLOCKWISE=-PI/2
#signals
signal flip
signal jump_out_signal
signal clash_up
signal dodging

##Signal to update health UI
signal update_health(value : int)
##Signal to update max health UI
signal update_max_health(value : int)
##Signal to update stagger UI
signal update_stagger
##Signal to update max stagger UI
signal update_max_stagger

#Player Stats
@export var movement_data : PlayerMovementData
@onready var aim_speed=movement_data.speed
@export var health: Health
@onready var _new_health := 0
@export var hitbox: HitBox
@export var max_ammo : int = 8
@export var ammo : int = 8
@export var ammo_reserves : int = 32
@export var TARGET_LOCK = preload("res://Component/effects/target_lock.tscn")
@onready var clash_power: ClashPower = $ClashPower
@onready var clash_timer: Timer = $ClashPower/ClashTimer
@onready var charge_timer: Timer = $ChargeTimer

@onready var stairs_detected : bool = false
@onready var stairs_release : bool = true
@onready var drop_down_platform_detected : bool = false


#Base FSM
enum States {IDLE, WALKING, JUMP, ATTACK, SPECIAL_ATTACK, WALL_STICK, PARRY, DODGE, SPRINTING,
FLIP,THRUST, HIT, STAGGERED}
@onready var state_machine: LimboHSM = $StateMachine
@onready var idle: LimboState = $StateMachine/Idle
@onready var walking: LimboState = $StateMachine/Walking
@onready var sprint: LimboState = $StateMachine/Sprint
@onready var jump_state: LimboState = $StateMachine/JumpState
@onready var falling_state: LimboState = $StateMachine/FallingState
@onready var landed: LimboState = $StateMachine/Landed
@onready var wall_stick: LimboState = $StateMachine/WallStick
@onready var aim: LimboState = $StateMachine/Aim
@onready var special_attack: LimboState = $StateMachine/SpecialAttack
@onready var parry_state: LimboState = $StateMachine/ParryState
@onready var dodge_state: LimboState = $StateMachine/DodgeState
@onready var flip_state: LimboState = $StateMachine/FlipState
@onready var flip_end_state: LimboState = $StateMachine/FlipEndState
@onready var staggered: LimboState = $StateMachine/Staggered
@onready var hit: LimboState = $StateMachine/Hit
@onready var recovery: LimboState = $StateMachine/Recovery
@onready var death: LimboState = $StateMachine/Death
@onready var dead: LimboState = $StateMachine/Dead


#Parry Success State
@onready var parry_success_state: LimboHSM = $StateMachine/ParrySuccessState
@onready var riposte: LimboState = $StateMachine/ParrySuccessState/Riposte
@onready var heavy_riposte: LimboState = $StateMachine/ParrySuccessState/HeavyRiposte
@onready var dodge_back: LimboState = $StateMachine/ParrySuccessState/DodgeBack
@onready var nothing: LimboState = $StateMachine/ParrySuccessState/Nothing
@onready var await_input: LimboState = $StateMachine/ParrySuccessState/AwaitInput

#Attack Combos
@onready var attack_state: LimboHSM = $StateMachine/AttackState
@onready var attack_1: LimboState = $StateMachine/AttackState/Attack1
@onready var attack_2: LimboState = $StateMachine/AttackState/Attack2
@onready var attack_3: LimboState = $StateMachine/AttackState/Attack3
@onready var special_combo: LimboState = $StateMachine/AttackState/SpecialCombo
@onready var special_combo_2: LimboState = $StateMachine/AttackState/SpecialCombo2
@onready var dash_attack: LimboState = $StateMachine/AttackState/DashAttack
@onready var heavy_attack_1: LimboState = $StateMachine/AttackState/HeavyAttack1
@onready var heavy_attack_2: LimboState = $StateMachine/AttackState/HeavyAttack2
@onready var heavy_attack_3: LimboState = $StateMachine/AttackState/HeavyAttack3
@onready var heavy_dash_attack: LimboState = $StateMachine/AttackState/HeavyDashAttack
@onready var heavy_counter: LimboState = $StateMachine/AttackState/HeavyCounter
@onready var attack_closer: LimboState = $StateMachine/AttackState/AttackCloser
@onready var charged_attack: LimboState = $StateMachine/AttackState/ChargedAttack
@onready var charging_attack: LimboState = $StateMachine/AttackState/ChargingAttack


@onready var attack_state_stack : Array[LimboState] = []
@onready var light_attacks : Array[String] = ["Attack", "Attack_2", "Attack_3"]
@onready var heavy_attacks : Array[String] = ["Heavy_Combo_1", "Heavy_Combo_2", "shotgun_finish"]

@onready var heavy_attacking : bool = false
@onready var atk_1_resume : bool = false
@onready var atk_2_resume : bool = false

@onready var cur_combo : LimboState = attack_1

#FSM for lock on
enum CombatStates {LOCKED, UNLOCKED}
@onready var combat_states: LimboHSM = $CombatStates
@onready var locked: LimboState = $CombatStates/Locked
@onready var unlocked: LimboState = $CombatStates/Unlocked

#FSM for combo attacks:
enum ComboStates {ATK_1,ATK_2,ATK_3,SPC_ATK,SPC_ATK_STRONG,SPC_ATK_BACK,THRUST}

var state: States = States.IDLE
var prev_state: States = States.IDLE

var combat_state: CombatStates = CombatStates.UNLOCKED
var combo_state: ComboStates = ComboStates.ATK_1

var double_jump_flag = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#wall jump state
var just_wall_jump = false
#parry state
var parry_stance=false
#attack combo up to 3
var atk_chain = 0
var sp_atk_chn = 0
#true = facing right fals= facing left
var face_right = true
var face_dir = clampi(-1, -1, 1)
var input_dir=Input.get_axis("walk_left","walk_right")
var wall_hold = false
#dodge dir
#var dodge_state = false

var dodge_dist = 0.0
var dodge_succ = false
var dodge_v = 0.0
var falling : bool = false
var jumping : bool = false

var cur_state = "IDLE"
var previous = "IDLE"
var atk_state="ATK_1"

#Animation var
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var shotty_animation_player: AnimationPlayer = $AnimatedSprite2D/Shotty/ShottyAnimationPlayer
#@onready var clash_visual: GPUParticles2D = $AnimatedSprite2D/GPUParticles2D
@onready var hit_fx: AnimatedSprite2D = $AnimatedSprite2D/hit_fx
@onready var hit_fx_2: AnimatedSprite2D = $AnimatedSprite2D/hit_fx/hit_fx2
@onready var hit_fx_player: AnimationPlayer = $HitFXPlayer
@onready var clash_aura_player: AnimationPlayer = $ClashAuraPlayer
@onready var clash_aura_fx: AnimatedSprite2D = $AnimatedSprite2D/heat_fx

@onready var hit_animation : String = "hit_landed"

@onready var interact_prompt_player: AnimationPlayer = $InteractPromptPlayer

@onready var speech: Label = $Speech
@onready var speech_timer: Timer = $Speech/SpeechTimer

#Cutscenes
@onready var anim_count : int = 0
@onready var cutscene_handler: CutsceneHandler = $CutsceneHandler
@onready var cutscene_sub_player: AnimationPlayer = $CutsceneSubPlayer





@onready var path_speed : int = 0 : set=set_path_speed
@onready var path_start : bool = false : set=set_path_start
@export var camera_pos : camera_position
#@onready var camera_2d: Camera2D = $Camera2D
var input_axis

var wall_normal : Vector2

#Quick-Time Events
@onready var qte_handler: QTEHandler = $QTEHandler
signal attack_qte
signal dodge_qte
signal block_qte
signal special_atk_qte
signal no_input_qte

@onready var interact_ready : bool = false
@onready var interact_menu_open : bool = false

@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var attack_timer = $AttackTimer

@onready var hit_timer = $HitTimer
@onready var parry_timer = $ParryTimer
@onready var dodge_timer = $DodgeTimer
@onready var dodge_buffer: Timer = $StateMachine/DodgeState/DodgeBuffer
@onready var starting_position : set = set_start_pos, get = get_start_pos
@onready var label = $STATE
@onready var heavy_attack_buffer_timer: Timer = $HeavyAttackBufferTimer
@onready var special_attack_buffer_timer: Timer = $SpecialAttackBufferTimer
@onready var reset_combo_flag : bool = false
@onready var heavy_attack_flag : bool = false
@onready var hit_buffer: Timer = $HitBuffer


@export var attack_timer_len : float = 0.3

@onready var hit_box: HitBox = $AnimatedSprite2D/HitBox
@onready var hb_collision: CollisionShape2D = $AnimatedSprite2D/HitBox/HBCollision
@onready var pb_rot: CollisionShape2D = $AnimatedSprite2D/ParryBox/PBRot
@onready var parry_box: ParryBox = $AnimatedSprite2D/ParryBox
@onready var counter_box_collision = $CounterBox/CounterBoxCollision
@onready var stagger: Stagger = $Stagger
@onready var stagger_recover: Timer = $StaggerRecover
@onready var flashlight: PointLight2D = $AnimatedSprite2D/Shotty/Flashlight

@onready var spread_boundary_1: RayCast2D = $AnimatedSprite2D/Shotty/SpreadBoundary1
@onready var spread_boundary_2: RayCast2D = $AnimatedSprite2D/Shotty/SpreadBoundary2
@onready var spread : int = 5
@onready var shotgun_lookat_mouse : bool = true
@onready var shotgun_lookat_target : bool = false
@onready var shoot_handler: ShootHandler = $ShootHandler
@onready var bullet_dir: Vector2 = Vector2.ZERO
@onready var reload_timer: Timer = $ShootHandler/ReloadTimer


@onready var sprite_fx: AnimatedSprite2D = $AnimatedSprite2D/sprite_fx
@onready var hurt_box_detect = $HurtBox/CollisionShape2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var hurt_box = $HurtBox
@onready var shotty = $AnimatedSprite2D/Shotty
@onready var sp_atk_hit_box = $AnimatedSprite2D/Shotty/SpAtkHitBox
@onready var sp_atk_cone = $AnimatedSprite2D/Shotty/SpAtkHitBox/SpAtkCone
@onready var cpu_particles_2d = $AnimatedSprite2D/Shotty/CPUParticles2D
@onready var audio_stream_player_2d = $AudioStreamPlayer2D
@onready var hit_sound = hit1
@onready var player_hit: GPUParticles2D = $AnimatedSprite2D/PlayerHit
@onready var hit_stop: HitStop = $HitStop

#Moving rooms
@onready var next_room_old : int = 0
@onready var next_room : String = ""
@onready var cur_room_old : int = 0
@onready var cur_room : String = ""
@onready var prev_room_old : int = 0
@onready var prev_room : String = ""
@onready var entry_pos : int = 0
@onready var prev_starting_pos : int = 0
@onready var in_door_way : bool = false

var local_door : entry_local = null
@onready var in_door_way_local : bool = false
@onready var door_locked : bool = false
@onready var door_local_exit : Vector2 = Vector2(0,0)

@onready var animated_door : bool = false

@onready var elevator_door : bool = false
@onready var elevator_connected : Node2D = null

@onready var game_controller : GameController

@onready var enemies : Array =[]


var knockback : Vector2
var kb_dir : Vector2 = Vector2.ZERO
var hit_success : bool = false
var forward_thrust : Vector2 = Vector2.ZERO

var hit_box_pos

var walk_anim : String = "walk"
var dodge_anim : String = "dodge"
var dodge_anim_run : String = "dodge"

var attack_combo = "Attack"
var sp_atk_combo = "shotgun_attack"
var air_atk : bool = false
var s_atk : bool = false
var move_axis : int = 1
var sp_atk_type = sp_atk_cone
var sp_atk_dmg :int = 1
var thrust : bool = false

@export var attacking : bool = false : set = set_attacking
@onready var charging := false : set = set_charging

var counter_flag : bool = false
@onready var counter_timer = $CounterTimer

var target
var target_string_test : String = "NONE"
var target_direction
var movement
var flip_speed
@onready var target_right : bool = false : set = set_target_right
var vector_away : Vector2 = Vector2.ZERO
var target_below : bool = false
var vel_y : float = 0.0
var hitstop_time_left : float
var high_target : bool = false

#locked on target info
@onready var target_testing = $TargetLocking/TargetTesting
@onready var target_locking = $TargetLocking
@onready var target_size_x=0
@onready var target_size_y=0
@onready var target_pos_y=0
@onready var target_pos_x=0
@onready var target_top=0
@onready var target_left_edge=0
@onready var target_right_edge=0
@onready var vel_x=0
#flipping
var high_target_jump_height
@onready var jump_out_timer = $JumpOutTimer
var flipped_over : bool = false
@onready var flip_buffer: Timer = $FlipBuffer


#multithreading
var thread := Thread.new()
var mutex := Mutex.new()


#DEBUG FLAGS TBR
var stuck : bool = false


func _ready():
	hit_box_pos=hit_box.position
	#hb_collision.disabled=true
	player = self
	pb_rot.disabled=true
	set_start_pos(global_position)
	sp_atk_type = sp_atk_cone
	load_player_data()
	Events.set_player_data.connect(save_player_data)
	Events.parried.connect(parry_success)
	Events.play_cutscene_segment.connect(play_cutscene)
	Events.checkpoint_reached.connect(save_player_data)
	Events.load_checkpoint.connect(load_player_data)
	Events.open_interact_menu.connect(open_interact_menu)
	Events.close_interact_menu.connect(close_interact_menu)
	Events.reset_player_data.connect(load_player_data)
	Events.in_door_way.connect(set_next_room)
	Events.reload_level_checkpoint.connect(reloaded)
	Events.boss_died.connect(boss_died)
	flip.connect(flip_over)
	jump_out_signal.connect(jump_out)
	_init_state_machine()
	_init_combat_state_machine()
	_init_parry_success_state_machine()
	_init_attack_states()
	#Events.add_inventory.emit()
	Events.update_inventory.emit("AmmoAmount",ammo)
	init_player_data()
	Events.get_player_data.connect(init_player_data)
	_new_health=health.health
	
	#Connecting knockback signals
	
	
func _init_state_machine():
	state_machine.initial_state=idle
	state_machine.initialize(self)
	state_machine.set_active(true)
	
	#Return to Idle
	state_machine.add_transition(walking, idle, &"return_to_idle")
	state_machine.add_transition(sprint, idle, &"return_to_idle")
	state_machine.add_transition(attack_state, idle, &"return_to_idle")
	state_machine.add_transition(landed, idle, &"return_to_idle")
	state_machine.add_transition(parry_state, idle, &"return_to_idle")
	state_machine.add_transition(dodge_state, idle, &"return_to_idle")
	state_machine.add_transition(parry_success_state, idle, &"return_from_parry")
	state_machine.add_transition(special_attack, idle, &"return_to_idle")
	state_machine.add_transition(recovery, idle, &"return_to_idle")
	
	#Landing
	state_machine.add_transition(jump_state, landed, &"landing")
	state_machine.add_transition(falling_state, landed, &"landing")
	state_machine.add_transition(dodge_state, landed, &"landing")
	state_machine.add_transition(flip_state, landed, &"landing")
	
	state_machine.add_transition(flip_state, flip_end_state, &"flipped_over")
	state_machine.add_transition(flip_end_state, landed, &"landing")
	
	#Recovery
	state_machine.add_transition(hit, recovery, &"recovering")
	state_machine.add_transition(staggered, recovery, &"recovering")
	
	#From Idle
	state_machine.add_transition(idle, walking, &"start_walking")
	state_machine.add_transition(idle, sprint, &"start_sprinting")
	state_machine.add_transition(idle, jump_state, &"start_jumping")
	state_machine.add_transition(idle, attack_state, &"start_attack")
	state_machine.add_transition(idle, dodge_state, &"start_dodge")
	state_machine.add_transition(idle, parry_state, &"start_parry")
	state_machine.add_transition(idle, flip_state, &"start_flip")
	state_machine.add_transition(idle, staggered, &"got_staggered")
	state_machine.add_transition(idle, hit, &"got_hit")
	state_machine.add_transition(idle, attack_state, &"attack_closer")
	
	#From Walking
	state_machine.add_transition(walking, sprint, &"start_sprinting")
	state_machine.add_transition(walking, jump_state, &"start_jumping")
	state_machine.add_transition(walking, attack_state, &"start_attack")
	state_machine.add_transition(walking, dodge_state, &"start_dodge")
	state_machine.add_transition(walking, parry_state, &"start_parry")
	state_machine.add_transition(walking, flip_state, &"start_flip")
	state_machine.add_transition(walking, staggered, &"got_staggered")
	state_machine.add_transition(walking, hit, &"got_hit")
	state_machine.add_transition(walking, attack_state, &"attack_closer")
	
	#From Sprinting
	state_machine.add_transition(sprint, walking, &"start_walking")
	state_machine.add_transition(sprint, jump_state, &"start_jumping")
	state_machine.add_transition(sprint, attack_state, &"start_attack")
	state_machine.add_transition(sprint, dodge_state, &"start_dodge")
	state_machine.add_transition(sprint, parry_state, &"start_parry")
	state_machine.add_transition(sprint, flip_state, &"start_flip")
	state_machine.add_transition(sprint, staggered, &"got_staggered")
	state_machine.add_transition(sprint, hit, &"got_hit")
	state_machine.add_transition(sprint, attack_state, &"attack_closer")
	
	#Resume walking
	state_machine.add_transition(attack_state, walking, &"resume_walking")
	
	#Hit
	state_machine.add_transition(parry_success_state, hit, &"got_hit")
	state_machine.add_transition(attack_state, hit, &"got_hit")
	
	state_machine.add_transition(hit, attack_state, &"start_attack")
	
	#Attack Combos
	#state_machine.add_transition(attack_state, special_attack, &"attack_to_special")
	#state_machine.add_transition(special_attack, attack_state, &"special_to_attack")
	state_machine.add_transition(jump_state, attack_state, &"start_attack")
	state_machine.add_transition(jump_state, special_attack, &"special_attack")
	state_machine.add_transition(jump_state, attack_state, &"attack_closer")
	state_machine.add_transition(dodge_state, attack_state, &"dash_attack")
	state_machine.add_transition(dodge_state, attack_state, &"heavy_dash_attack")
	state_machine.add_transition(dodge_state, attack_state, &"combo_resume")
	state_machine.add_transition(dodge_state, attack_state, &"heavy_counter")
	state_machine.add_transition(dodge_state, special_attack, &"dodge_shoot")
	state_machine.add_transition(dodge_state, flip_state, &"start_flip")
	
	state_machine.add_transition(dodge_state, dodge_state, &"dodge_chain")
	
	state_machine.add_transition(falling_state, attack_state, &"start_attack")
	state_machine.add_transition(falling_state, special_attack, &"special_attack")
	
	
	state_machine.add_transition(idle, special_attack, &"special_attack")
	state_machine.add_transition(walking, special_attack, &"special_attack")
	state_machine.add_transition(sprint, special_attack, &"special_attack")
	
	state_machine.add_transition(idle, aim, &"aim")
	state_machine.add_transition(walking, aim, &"aim")
	state_machine.add_transition(sprint, aim, &"aim")
	state_machine.add_transition(jump_state, aim, &"aim")
	state_machine.add_transition(attack_state, aim, &"aim")
	state_machine.add_transition(aim, special_attack, &"shoot")
	
	state_machine.add_transition(special_attack, falling_state, &"return_from_special")
	#state_machine.add_transition(idle, special_attack, &"special_attack")
	state_machine.add_transition(attack_state, dodge_state, &"start_dodge")
	
	state_machine.add_transition(attack_state, hit, &"interrupt_knockback")
	
	#Charge Attacks
	#state_machine.add_transition(attack_state, charging_attack, &"charge_attack")
	#state_machine.add_transition(charging_attack, attack_state, &"charged")
	#state_machine.add_transition(charging_attack, attack_2, &"charged_2")
	#state_machine.add_transition(charging_attack, attack_3, &"charged_3")
		
	#Flipping State
	state_machine.add_transition(flip_state, jump_state, &"jump_out")
	state_machine.add_transition(flip_state, attack_state, &"flip_attack")
	state_machine.add_transition(flip_state, wall_stick, &"hit_wall")
	state_machine.add_transition(flip_state, special_attack, &"flip_shoot")
	
	state_machine.add_transition(flip_end_state, jump_state, &"jump_out")
	state_machine.add_transition(flip_end_state, attack_state, &"flip_attack")
	state_machine.add_transition(flip_end_state, wall_stick, &"hit_wall")
	state_machine.add_transition(flip_end_state, special_attack, &"flip_shoot")
	
	
	#Counter Success
	state_machine.add_transition(parry_state, parry_success_state, &"parry_successful")
	state_machine.add_transition(dodge_state, parry_success_state, &"dodge_successful")

	#Wall Stick
	state_machine.add_transition(jump_state, wall_stick, &"stick_to_wall")
	state_machine.add_transition(wall_stick, jump_state, &"jump_off_wall")
	state_machine.add_transition(wall_stick, falling_state, &"fall_off_wall")
	
	#Player death
	state_machine.add_transition(state_machine.ANYSTATE, death, &"die")
	state_machine.add_transition(death, dead, &"dead")



func _init_combat_state_machine():
	combat_states.initial_state=unlocked
	combat_states.initialize(self)
	combat_states.set_active(true)
	
	combat_states.add_transition(locked, unlocked, &"unlocking")
	combat_states.add_transition(unlocked, locked, &"locking_on")
	
func _init_parry_success_state_machine():
	parry_success_state.initial_state=await_input
	
	parry_success_state.add_transition(await_input, riposte, &"riposte")
	parry_success_state.add_transition(await_input, heavy_riposte, &"heavy_riposte")
	parry_success_state.add_transition(await_input, dodge_back, &"dodge_back")
	parry_success_state.add_transition(await_input, nothing, &"do_nothing")
	
func _init_attack_states():
	attack_state.initial_state=attack_1

	attack_state.add_transition(attack_1, attack_1, &"next_attack")
	#attack_state.add_transition(attack_2, attack_3, &"next_attack")
	#attack_state.add_transition(attack_3, attack_1, &"next_attack")
	
	
	#attack_state.add_transition(attack_1, special_combo, &"special_combo")
	#attack_state.add_transition(attack_2, special_combo, &"special_combo")
	attack_state.add_transition(attack_state.ANYSTATE, dash_attack, &"dash_attack")
	attack_state.add_transition(attack_state.ANYSTATE, heavy_dash_attack, &"heavy_dash_attack")
	attack_state.add_transition(attack_state.ANYSTATE, heavy_counter, &"heavy_counter")
	attack_state.add_transition(attack_state.ANYSTATE, attack_closer, &"attack_closer")
	
	#Heavy attack Combos
	attack_state.add_transition(attack_1, heavy_attack_1, &"heavy_combo")
	attack_state.add_transition(attack_1, special_combo_2, &"heavy_finisher")

	#attack_state.add_transition(heavy_attack_2, special_combo_2, &"next_attack")
	
	attack_state.add_transition(attack_1, charging_attack, &"charge_attack")
	attack_state.add_transition(heavy_attack_1, charging_attack, &"charge_attack")
	attack_state.add_transition(charging_attack, charging_attack, &"charge_attack")
	#attack_state.add_transition(attack_2, charging_attack, &"charge_attack")
	#attack_state.add_transition(attack_3, charging_attack, &"charge_attack")
	
	#attack_state.add_transition(heavy_attack_2, charging_attack, &"charge_attack")
	#attack_state.add_transition(heavy_attack_3, charging_attack, &"charge_attack")
	
	attack_state.add_transition(charging_attack, charged_attack, &"charged")
	
	#attack_state.add_transition(charged_attack, attack_2, &"combo_resume")
	#attack_state.add_transition(charged_attack, attack_3, &"combo_resume_2")
	attack_state.add_transition(charged_attack, attack_1, &"next_attack")
	
	
	#Resume Combos
	#attack_state.add_transition(special_combo, attack_2, &"combo_resume")
	#attack_state.add_transition(special_combo, attack_3, &"combo_resume_2")
	
	attack_state.add_transition(attack_state.ANYSTATE, attack_1, &"reset_combo")

func _process(_delta):
	
	
	knockback=clamp(knockback, Vector2(-400, -400), Vector2(400, 400) )
	if not cutscene_handler.actor_control_active:
		
		if qte_handler.actor_control_active:
			qte_input()
		return
	elif state_machine.get_active_state()==death or state_machine.get_active_state()==dead:
		move_and_slide()
		
		velocity=Vector2.ZERO
		apply_gravity(_delta)
		return
#
	input_axis = Input.get_axis("walk_left", "walk_right")
	vel_x=velocity.x
	#current_state_label()
	get_target_info()
	#previous_state()
	atk_state_debug()
#
	dodge(input_axis)
	
		
	if(state_machine.get_active_state()!=dodge_state\
	 and state_machine.get_active_state()!=special_attack\
	 and state_machine.get_active_state()!=flip_state):
		parry()
		if not interact_menu_open:
			attack_handler()
		else:
			pass
		update_animation(input_axis)
	elif state_machine.get_active_state()==flip_state:
		break_out()
	elif state_machine.get_active_state()==dodge_state:
		if Input.is_action_just_pressed("attack"):
			dash_attack_enter()
		elif Input.is_action_just_pressed("special_attack"):
			dash_shoot_attack()
		else:
			pass
	#
	lockon()
	shotgun_unlock()
	enter_door()
	climb_stairs()
	drop_down()
	interact()
	stick_to_wall()
	flip_over()
	
	if Input.is_action_just_pressed("DEBUG_KEY"):
		clash_power.clash_power+=1
	

signal vel_y_changed

#func set_velocity(_value : Vector2) -> void:
	#super(_value)
	#if velocity.y<0:
		#vel_y_changed.emit(_value)
		#print_debug("ruh roh")
	

func _physics_process(delta):
	vel_y=velocity.y
	
	if not cutscene_handler.actor_control_active or not qte_handler.actor_control_active:
		apply_gravity(delta)
		cutscene_acceleration(cutscene_handler.cutscene_dir, delta, cutscene_handler.cutscene_speed)
		if (cutscene_handler.cutscene_dir<0 and velocity.x>0) or (cutscene_handler.cutscene_dir>0 and velocity.x<0):
			push_error("something wrong")
		move_and_slide()
		

		return
	
	elif state_machine.get_active_state()==flip_state:
		flipping(delta)
		sp_atk()
		move_and_slide()
		
		if is_on_floor():
			if state_machine.get_active_state()==jump_state or (state_machine.get_active_state()==flip_state and flipped_over):
				state_machine.dispatch(&"landing")
				
			
	elif state_machine.get_active_state()==staggered:
		move_and_slide()
		apply_gravity(delta)
		velocity.x=0
	elif state_machine.get_active_state()==death or state_machine.get_active_state()==dead:
		move_and_slide()
		apply_gravity(delta)
		return
	else:
		if combat_states.get_active_state()==locked:
			locked_combat()	
#
		##if dodge_state == true:
			##state = States.DODGE
		
		## Add the gravity.
		if(parry_stance==false) and state_machine.get_active_state()!=attack_state:
			apply_gravity(delta) 
		var input_axis = Input.get_axis("walk_left", "walk_right")
		
		#if input_axis<0:
			#face_right=true
			#face_dir=1
		#elif input_axis>0:
			#face_right=false
			#face_dir=-1
		if combat_states.get_active_state()==locked:
			if target_right:
				face_right=false
				face_dir=-1
			else:
				face_right=true
				face_dir=1
		else:
			if animated_sprite_2d.scale.x>0:
				face_right=false
				face_dir=-1
			else:
				face_right=true
				face_dir=1
		##Dodge back on success

		

		#wall_hold = false
		if(state_machine.get_active_state()!=dodge_state and parry_stance==false \
		and state_machine.get_active_state()!=flip_state and state_machine.get_active_state()!=attack_state):
			if not interact_menu_open:
				handle_wall_jump(wall_hold, delta)
				jump(input_axis, delta)
				handle_acceleration(input_axis, delta)
				if heavy_attack_flag:
					handle_air_acceleration(input_axis, delta)
				apply_friction(input_axis, delta)
				apply_air_resistance(input_axis, delta)
				shotgun_free_rotate()
			sp_atk()
		elif state_machine.get_active_state()==attack_state:
			sp_atk()
		
		
		var was_on_floor = is_on_floor()
		velocity=velocity + knockback
		move_and_slide()
		var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
		if just_left_ledge:
			coyote_jump_timer.start()
		if is_on_floor():
			just_wall_jump = false
		

		toggle_light()
		if is_on_floor():
			knockback = lerp(knockback, Vector2.ZERO, 0.5)
		else:
			knockback.x = lerpf(knockback.x, 0, 0.3)
			knockback.y = lerpf(knockback.y, 0, 0.6)
		forward_thrust = lerp(forward_thrust, Vector2.ZERO, 0.6)
		#wall hold check
		wall_sticking(wall_hold)

# Add the gravity.
func apply_gravity(delta):
	if not is_on_floor():
		if s_atk:
			velocity.y += gravity/3 * movement_data.gravity_scale * delta
		else:
			velocity.y += gravity * movement_data.gravity_scale * delta
	
#condtions to return to idle
func return_to_idle():
	if is_on_floor() and state_machine.get_previous_active_state()==flip_state and flipped_over:
		#"flip end")
		state_machine.dispatch(&"return_to_idle")
		set_collision_mask_value(16384, true)
		#attacking=false
	
# Handle jump.
func jump(input_axis, delta):

	if is_on_floor(): double_jump_flag = true
	
	if is_on_floor() or coyote_jump_timer.time_left>0.0:
		if Input.is_action_just_pressed("jump"):
			#state = States.JUMP
			state_machine.dispatch(&"start_jumping")
			velocity.y = movement_data.jump_velocity
			
	elif not is_on_floor() and parry_stance==false and state_machine.get_previous_active_state()!=flip_state and state_machine.get_active_state()!=wall_stick:
		#state = States.JUMP
		if Input.is_action_just_released("jump") and velocity.y<movement_data.jump_velocity/2:
			
			#velocity.y = movement_data.jump_velocity/2
			#state = States.JUMP
			state_machine.dispatch(&"start_jumping")
		if Input.is_action_just_pressed("jump") and double_jump_flag == true and just_wall_jump == false:
			
			velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.acceleration*10 * delta)
			velocity.y = movement_data.jump_velocity *0.8
			double_jump_flag = false
			#state = States.JUMP
			state_machine.dispatch(&"start_jumping")

func stick_to_wall() -> void:
	if Input.is_action_pressed("sprint")  and is_on_wall_only():
			wall_hold=true

func wall_sticking(_wall_hold : bool):
	if just_wall_jump: return
	
	if _wall_hold:
		velocity.x =0
		velocity.y = 0
		state_machine.dispatch(&"stick_to_wall")
	
	
	
	if state_machine.get_active_state()==wall_stick:
		if state_machine.get_previous_active_state()!=flip_state and state_machine.get_previous_active_state()!=flip_end_state:
			if Input.is_action_just_released("sprint"):
				wall_hold = false
				state_machine.dispatch(&"fall_off_wall")
				#assert(velocity.y!=0)
#breaking out of a flip. Test without timer later
func break_out():
	
	if Input.is_action_just_pressed("jump") and not Input.is_action_pressed("sprint"):
		state_machine.dispatch(&"jump_out")
		jump_out_signal.emit(30)
	elif Input.is_action_just_pressed("attack"):
		attack_combo="Flip_Attack"
		state_machine.dispatch(&"flip_attack")
		jump_out(15)
		
		
#jump out of flip
func jump_out(jumpout_vel : float):
	knockback.x=jumpout_vel
	#print_debug(knockback.x)
	#Kprint_debug(vector_away.x)
	var jump_left
	if global_position.x - target.global_position.x > 0:
		jump_left=true
	else:
		jump_left=false
	if not jump_left:
		knockback.x = knockback.x*-1
	else:
		knockback.x=knockback.x
	velocity.y=movement_data.jump_velocity*0.8
	hit_stop.hit_stop(1,0)
	set_collision_mask_value(15, true)


func handle_wall_jump(wall_hold, delta):
	if not is_on_wall_only(): return
	if not Input.is_action_pressed("sprint"): return
	var _jump_vel=50
	wall_normal = get_wall_normal()


	if wall_hold == true:
		#state = States.WALL_STICK
		
			
		if (Input.is_action_just_pressed("walk_right") and wall_normal==Vector2.RIGHT) \
		or (Input.is_action_just_pressed("walk_left") and wall_normal==Vector2.LEFT) \
		 or Input.is_action_just_pressed("jump"):
			state_machine.dispatch(&"jump_off_wall")
			#knockback.x=-_jump_vel
			#knockback.y=movement_data.jump_velocity
			velocity.x = move_toward(velocity.x, movement_data.speed * wall_normal.x * 1.5, movement_data.acceleration*10 * delta)
			velocity.y = movement_data.jump_velocity
			just_wall_jump = true
			wall_hold=false
		else:
			state_machine.dispatch(&"stick_to_wall")
			velocity.x =0
			velocity.y = 0

		
	if wall_hold == true:
		velocity.x =0
		velocity.y = 0

	else:
		gravity = 980



func apply_air_resistance(input_axis, delta):
	if input_axis == 0 and not is_on_floor() and not s_atk:
		velocity.x = move_toward(velocity.x, 0 , movement_data.air_resistance * delta)
# Get the input direction and handle the movement/deceleration.
func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)
		
# Apply friction after dtopping.
func handle_acceleration(input_axis, delta):
	if not is_on_floor(): return
	if charging: return
	if s_atk: return
	if input_axis != 0:
		if state_machine.get_active_state()==aim:
			velocity.x = move_toward(velocity.x, aim_speed * input_axis, movement_data.acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.acceleration * delta)
		if state_machine.get_active_state()==idle:
			state_machine.dispatch(&"start_walking")

func talk(speech_text : String):
	speech.text=speech_text
	speech.visible=true
	speech_timer.start(3)

func _on_speech_timer_timeout() -> void:
	speech.visible=false

# Movement for cutscenes		
func cutscene_acceleration(_dir, delta, _speed : String):
	
	var _cutscene_speed : int = 0
	match _speed:
		"slow":
			_cutscene_speed=movement_data.speed/3
		"fast":
			_cutscene_speed=movement_data.speed
		"medium":
			_cutscene_speed=movement_data.speed/2
			#print (_cutscene_speed)
	if _dir!=0:
		velocity.x = (_cutscene_speed) * _dir
		#Kprint_debug(velocity.x, " ", _cutscene_speed, " ", _dir)
	else:
		velocity.x=0
		
		
func set_movement_data(value : int) -> void:
	match value:
		0:
			movement_data = load("res://DefaultMovementData.tres")
		1:
			movement_data = load("res://SlowMovementData.tres")
		2:
			movement_data = load("res://FasterMovementData.tres")
#

func handle_air_acceleration(input_axis, delta):
	if is_on_floor(): return
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.air_acceleration * delta)

func update_animation(input_axis):
	##disable moving when knocked back with high knockback strength
	if knockback.x>50:
		return
	if charging:
		return
	##Set shotgun scale to default
	
	
	
	if Input.is_action_pressed("up"):
		if Input.is_action_pressed("walk_right"):
			parry_box.rotation=-(PI/4)
		elif Input.is_action_pressed("walk_left"):
			parry_box.rotation=(PI/4)
		else:
			if parry_box.scale.x<0:
				parry_box.rotation=(PI/2)
			else:
				parry_box.rotation=-(PI/2)
	elif Input.is_action_just_released("up") :
		parry_box.rotation=0

	
	if combat_states.get_active_state()!=locked:
		if input_axis != 0:
		
			if input_axis<0:
				animated_sprite_2d.scale.x=-1
				
			else:
				animated_sprite_2d.scale.x=1
				
					
			#if state_machine.get_previous_active_state()!=attack_state and s_atk==false and not attack_timer.is_stopped():
			if state_machine.get_previous_active_state()!=attack_state\
			and state_machine.get_active_state()!=hit\
			 and s_atk==false:
				#state = States.WALKING
				
				if Input.is_action_pressed("sprint"):

					if is_on_wall():
						wall_hold=true
					if combat_states.get_active_state()!=locked:
						walk_anim="run"
						state_machine.dispatch(&"start_sprinting")
					else:
						state_machine.dispatch(&"start_walking")
					movement_data = load("res://FasterMovementData.tres")
				elif Input.is_action_just_released("sprint"):
					wall_hold=false
					movement_data = load("res://DefaultMovementData.tres")
					walk_anim="walk"
					state_machine.dispatch(&"start_walking")
				else:
					walk_anim="walk"
					state_machine.dispatch(&"start_walking")
					
	else:
		if not target_right:
			animated_sprite_2d.scale.x=-1
			assert(animated_sprite_2d.scale.x==-1)
			if input_axis>0:
				walk_anim="walk_back"
			else:
				walk_anim="walk"
		else:
			animated_sprite_2d.scale.x=1
			if input_axis>0:
				walk_anim="walk"
			else:
				walk_anim="walk_back"
		if (state_machine.get_previous_active_state()!=attack_state and s_atk==false) and input_axis!=0:
			state_machine.dispatch(&"start_walking")
		if Input.is_action_pressed("sprint"):
			movement_data = load("res://FasterMovementData.tres")
		elif Input.is_action_just_released("sprint"):
			movement_data = load("res://DefaultMovementData.tres")
	if (Input.is_action_just_released("walk_left") or Input.is_action_just_released("walk_right")) and input_axis==0:
		#state = States.IDLE
		state_machine.dispatch(&"return_to_idle")
		
	if is_on_floor():
		jumping=false
		if state_machine.get_previous_active_state()==jump_state:
			falling=false
			state_machine.dispatch(&"return_to_idle")
	
		
		
func attack_handler():
	if state_machine.get_active_state()==hit or state_machine.get_active_state()==staggered:
		return
	
	var anim_player_time : float = anim_player.current_animation_position
	
	if Input.is_action_pressed("attack"):
		if state_machine.get_active_state()==idle and (attacking or charging):
			return
		elif state_machine.get_active_state()==attack_state and charging:
			return
			
		if attack_state.get_active_state()==attack_1:
			if attacking:
				return
			else:
				attacking=true
	
		if charge_timer.is_stopped():
			
			#attacking=true
			#print_debug(state_machine.get_active_state())
			assert(not charging)
			if hit_box.damage>=clash_power.clash_power or clash_power.clash_power==0:
				charge_timer.start(0.01)
			else:
				charge_timer.start(0.2)
			#attack_timer.start(.2)
			#attack_timer.paused=true
		else:
			return

			
	elif Input.is_action_just_released("attack"):
		
		if not charge_timer.is_stopped():
			charge_timer.stop()
			
		if not charging and not attacking:
			#charging=false
			light_attack()
		else:
			charging=false
			#return
			
	
		charging=false
		
		if state_machine.get_active_state()==idle and attacking:
			attacking=false
			
			
		elif state_machine.get_active_state()==attack_state:
			
			if state_machine.get_active_state()==charged_attack:
				return
			if attacking:
				attacking=false
			if not charging:
				#charging=false
				if anim_player.current_animation_position>=anim_player.current_animation_length and\
				hit_box.damage>=clash_power.clash_power or clash_power.clash_power==0:
					pass
				else:
					light_attack()
			else:
				charging=false
				
				if attack_timer.time_left<0.01:
					attack_timer.start(0.05)
					attack_timer.paused=false
				else:
					attack_timer.start(0.1)
					attack_timer.paused=false
				
			
			
	
func heavy_combos():
	if Input.is_action_pressed("special_attack") and not Input.is_action_pressed("attack"):
		
		if state_machine.get_active_state()==idle and (attacking or charging):
			return
		elif state_machine.get_active_state()==attack_state and charging:
			return
			
		if attack_state.get_active_state()==heavy_attack_1:
			if attacking:
				return
			else:
				attacking=true
	
		if charge_timer.is_stopped():
			heavy_attacking=true
			#attacking=true
			charging_attack.attack=heavy_attack_1.attack
			print_debug(state_machine.get_active_state())
			assert(not charging)
			if hit_box.damage>=clash_power.clash_power or clash_power.clash_power==0:
				charge_timer.start(0.01)
			else:
				charge_timer.start(0.2)
			#attack_timer.start(.2)
			#attack_timer.paused=true
		else:
			return
	elif Input.is_action_just_released("special_attack") and not Input.is_action_pressed("attack"):
		
		
		
		if not charge_timer.is_stopped():
			charge_timer.stop()
			
		if not charging and not attacking:
			#charging=false
			heavy_attack()
		else:
			charging=false
			#return
			
	
		charging=false
		
		if state_machine.get_active_state()==idle and attacking:
			attacking=false
			
			
		elif state_machine.get_active_state()==attack_state:
			
			if state_machine.get_active_state()==charged_attack:
				return
			if attacking:
				attacking=false
			if not charging:
				#charging=false
				if anim_player.current_animation_position>=anim_player.current_animation_length and\
				hit_box.damage>=clash_power.clash_power or clash_power.clash_power==0:
					pass
				else:
					heavy_attack()
			else:
				charging=false
				
				if attack_timer.time_left<0.01:
					attack_timer.start(0.05)
					attack_timer.paused=false
				else:
					attack_timer.start(0.1)
					attack_timer.paused=false
			
		
func _on_charge_timer_timeout() -> void:
	
	print_debug(hit_box.damage,", ", clash_power.clash_power)
	if hit_box.damage>=clash_power.clash_power or clash_power.clash_power==0:
		light_attack()
	else:
		if  not hit_box.heavy_attack:
			hit_box.heavy_attack=true
		if heavy_attacking:
			attack_state.dispatch(&"heavy_combo")
			attack_state.dispatch(&"charge_attack")
			charging_attack.anim_second+=0.1
		else:
			if state_machine.get_active_state()!=attack_state:
				state_machine.dispatch(&"start_attack")
			attack_state.dispatch(&"charge_attack")
			charging_attack.anim_second+=0.1


func start_attack_timer() -> void:
	attack_timer.start(0.2)
		
func light_attack() -> void:
	
	if combat_states.get_active_state()!=locked:
		regular_attack()
	else:
		assert(target!=null)
		var _dist_to_target_x=abs(global_position.x-target.global_position.x)
		var _dist_to_target_y=abs(global_position.y-target.global_position.y)
		if Input.is_action_pressed("sprint") and (_dist_to_target_x>50 or _dist_to_target_y>50):
			if target.is_on_floor():
				attack_closer.closing_dir= global_position.direction_to(Vector2(target.global_position.x, global_position.y))
			else:
				attack_closer.closing_dir= global_position.direction_to(target.global_position)
			closing_attack()
		else:
			regular_attack()
	heavy_attack_buffer_timer.start()
	#attacking=true
	
	

func regular_attack() -> void:
	#if attacking and not charging:
		#return
	if state_machine.get_active_state()==parry_success_state:
		return
	
	#attack_timer.start()
	else:
		if state_machine.get_active_state()!=attack_state:
			attack_timer.paused=true
			
		if counter_flag:
			attack_combo = "Attack_Counter"
			hit_box.set_damage(3)
			hit_sound = hit1
			AudioStreamManager.play(swing1)
		elif target_below:
			attack_combo = "Attack_Down"
			hit_box.set_damage(2)
			hit_sound = hit1
			AudioStreamManager.play(swing1)
			velocity.y=movement_data.jump_velocity/2
		else:
			hit_box.set_damage(1)
			
			attack_sfx()
			print_debug(attack_state.get_active_state())
			if state_machine.get_active_state()==attack_state:
				var _prev_attack : LimboState
				if not attack_state_stack.is_empty():
					_prev_attack=attack_state_stack.pop_front()
				else:
					_prev_attack=attack_1
					
				if attack_state.get_active_state()==charging_attack:
					#if not attacking:
						#attacking=true
					attack_state.dispatch(&"charged")
				else:
					state_machine.dispatch(&"next_attack")
					
				#elif attack_state.get_active_state()==charged_attack:
					#print_debug(attack_state.get_active_state())
					#attack_state.dispatch(&"next_attack")
				#
				#else:
					#attack_state.dispatch(&"charge_attack")
					#if atk_1_resume:
						#attack_state.dispatch(&"combo_resume")
					#elif atk_2_resume:
						#attack_state.dispatch(&"combo_resume_2")
					
						
					
					
				
			else:
				#attack_state.initial_state=attack_1
				state_machine.dispatch(&"start_attack")
			#await anim_player.animation_finished
			#attack_timer.paused=false
			
func attack_sfx() -> void:
	if not attack_timer.is_stopped():
		if atk_chain == 0:
			#attack_combo = "Attack"
			#hit_sound = hit1
			AudioStreamManager.play(swing1)

		elif atk_chain == 1 and sp_atk_chn<1:
			#attack_combo = "Attack_2"
			#hit_sound = hit2
			AudioStreamManager.play(swing2)
		
		elif atk_chain == 2:
			#attack_combo = "Attack_3"
			#hit_sound = hit3
			AudioStreamManager.play(swing3)
		elif sp_atk_chn>=1:
			attack_combo = "Attack_Chain"
			hit_sound = hit2
			AudioStreamManager.play(swing2)
#Buffer Timeout, Regular Attack
func _on_heavy_attack_buffer_timer_timeout() -> void:
	pass
	#regular_attack()
	
	
	#set_state(state, States.ATTACK)
	#if state_machine.get_active_state()==attack_state:
		#if atk_1_resume:
			#attack_state.dispatch(&"combo_resume")
		#elif atk_2_resume:
			#attack_state.dispatch(&"combo_resume_2")
		#else:
			#if attack_state.get_active_state()==attack_3 or attack_state.get_active_state()==special_combo_2:
				#attack_state.dispatch(&"reset_combo")
			#else:
				#attack_state.dispatch(&"next_attack")
	#else:
		#attack_state.initial_state=attack_1
		#state_machine.dispatch(&"start_attack")
	#await anim_player.animation_finished
	#attack_timer.paused=false
	
func heavy_attack():
	heavy_attack_buffer_timer.stop()
	hit_buffer.stop()
	if state_machine.get_active_state()!=attack_state:
		attack_timer.paused=true
	hit_box.set_damage(1)
	#if counter_flag:
		#attack_state.dispatch(&"heavy_counter")
		#state_machine.dispatch(&"start_attack")
	if counter_flag:
		state_machine.dispatch(&"heavy_counter")
	else:
		attack_state.dispatch(&"heavy_combo")
	#if not attack_timer.is_stopped():
		#if atk_chain == 0:
			##attack_combo = "Attack"
			##hit_sound = hit1
			#AudioStreamManager.play(swing1)
	#attack_state.initial_state=heavy_attack_1
	#state_machine.dispatch(&"start_attack")

func _on_special_combo_2_exited() -> void:
	shotty_animation_player.play("shotgun_reset")

func _on_special_combo_exited() -> void:
	shotty_animation_player.play("shotgun_reset")

	
	
func dash_attack_enter():
	if state_machine.get_active_state()==attack_state:
		return
	attack_timer.paused=true
	attack_state.dispatch(&"dash_attack")
	state_machine.dispatch(&"dash_attack")
	#attack_combo = "Attack_Dash"
	#hit_sound = hit1
	#AudioStreamManager.play(swing1)
	##set_state(state, States.ATTACK) 
	
func dash_shoot_attack():
	state_machine.dispatch(&"dodge_shoot")
	
func heavy_dash_attack_enter():
	return
	if state_machine.get_active_state()==attack_state:
		return
	attack_timer.paused=true
	attack_state.dispatch(&"heavy_dash_attack")
	state_machine.dispatch(&"heavy_dash_attack")

func closing_attack() -> void:
	state_machine.dispatch(&"attack_closer")
	attack_state.dispatch(&"attack_closer")

func sp_atk():
	if s_atk:
		return
	if state_machine.get_previous_active_state()==flip_state or state_machine.get_active_state()==flip_state:
		set_shotgun_free_rotate(false)
		shotty.look_at(target.global_position)
	#else:
		#set_shotgun_free_rotate(true)
	
	
	if state_machine.get_active_state()!=parry_success_state \
	 and state_machine.get_active_state()!=special_attack and state_machine.get_active_state()!=attack_state:
		aim_and_shoot()
	else:
		if Input.is_action_pressed("sprint"):
			aim_and_shoot()
		else:
			heavy_combos()
		
	
	#if Input.is_action_pressed("attack") and not special_attack_buffer_timer.is_stopped():
		#special_attack_buffer_timer.stop()
		#heavy_attack()
		
func aim_and_shoot():
	
	if state_machine.get_active_state()==flip_state or state_machine.get_active_state()==flip_end_state:
		if Input.is_action_just_pressed("special_attack"):
			state_machine.dispatch(&"flip_shoot")
	else:
		if (Input.is_action_pressed("special_attack")) and not attacking and not Input.is_action_pressed("attack"):
			if ammo==0:
				if not reload_timer.is_stopped():
					return
				else:
					reload_gun()
			else:
				state_machine.dispatch(&"aim")
				if not is_on_floor():
					slow_down_aim()
				else:
					end_slow_down()
		elif Input.is_action_just_released("special_attack"):
			state_machine.dispatch(&"shoot")
			end_slow_down()

func slow_down_aim():
	Engine.time_scale=0.5

func end_slow_down():
	Engine.time_scale=1

func get_clash_power() -> int:
	return clash_power.clash_power


		
		
		
		
		#if not attacking:
			#attacking=true
			#match attack_state.get_active_state():
				#attack_1:
					#heavy_attack()
				#attack_2:
					#heavy_attack()
				#attack_3:
					#attack_timer.paused=true
					#finishers()
					
func set_attacking(value : bool) -> void:
	#if value==true:
		#print_debug("begin_attack")
	#else:
		#print_debug("ending attack")
	attacking=value

func set_charging(value : bool) -> void:
	#if value==true:
		#print_debug("begin_charge")
	#else:
		#print_debug("ending charge")
	charging=value

func finishers() -> void:
	heavy_attack_buffer_timer.stop()
	hit_buffer.stop()
	if state_machine.get_active_state()!=attack_state:
		attack_timer.paused=true
	hit_box.set_damage(3)
	state_machine.dispatch(&"heavy_finisher")

func _on_special_attack_buffer_timer_timeout() -> void:
	if state_machine.get_active_state()==attack_state:
		if attack_timer.is_stopped():
			attack_timer.start(1.5)
			attack_timer.paused=false
		
		attack_state.dispatch(&"heavy_finisher")
	else:
		
		if attack_timer.is_stopped():
			attack_timer.start(0.3)
			attack_timer.paused=false
		
		state_machine.dispatch(&"special_attack")
			
	attack_timer.paused = false

func gun_cone(spread : int) -> Array[int]:
	var _left_boundary : float = spread_boundary_2.rotation_degrees
	var _right_boundary : float = spread_boundary_1.rotation_degrees
	var _cone_angle :float = (_left_boundary) - (_right_boundary)
	var _spread_angle : float = _cone_angle/spread
	var _bullet_spawn_angle : float =shotty.global_rotation_degrees - _spread_angle
	var _bullet_spawn_angles : Array[int]
	for i in spread:
		
		_bullet_spawn_angles.push_front(_bullet_spawn_angle)
		_bullet_spawn_angle+=_spread_angle
	return _bullet_spawn_angles

func _on_special_attack_entered() -> void:
	pass
	#var _bullet_dirs : Array[int] = gun_cone(spread)
	#for i in spread:
		#bullet_dir = rotation_to_direction(_bullet_dirs[i])
		#shoot_handler.shoot_bullet()

func shotgun_shoot() -> void:
	
	var _bullet_dirs : Array[int] = gun_cone(spread)
	#for i in _bullet_dirs:
		#print_debug(_bullet_dirs[i])
	#print_debug(spread_boundary_1.rotation_degrees, ", ", spread_boundary_2.rotation_degrees)
	Events.remove_ammo.emit()
	ammo-=1
	shoot_handler.manuel_rotation=true
	for i in spread:
		bullet_dir = rotation_to_direction(_bullet_dirs[i])
		print_debug(_bullet_dirs[i])
		shoot_handler.bullet_rotation = _bullet_dirs[i]
		shoot_handler.shoot_bullet()
		

func shotgun_recoil() -> void:
	Events.camera_shake.emit(1,20)

func reload_gun() -> void:
	reload_timer.start()

func _on_reload_timer_timeout() -> void:
	if ammo>=max_ammo:
		reload_timer.stop()
	else:
		ammo+=1
		Events.reload_ammo.emit()
		shotty_animation_player.stop()
		shotty_animation_player.play("reload")
		if ammo>=max_ammo:
			reload_timer.stop()

func reload_gun_amount(_reload_amount : int) -> void:
	ammo+=_reload_amount
	Events.reload_ammo.emit(_reload_amount)
	shotty_animation_player.stop()
	shotty_animation_player.play("rapid_reload")

func rotation_to_direction(_rotation_degrees : int) -> Vector2:
	 # Convert rotation from degrees to radians (skip if already in radians)
	var _rotation_radians = deg_to_rad(_rotation_degrees)
	# Calculate direction vector
	var direction = Vector2(cos(_rotation_radians), sin(_rotation_radians))
	# Normalize the vector (optional, but ensures length = 1)
	direction = direction.normalized()
	#print_debug(direction)
	return direction

func shotgun_free_rotate():
	if shotgun_lookat_target:
		shotgun_point_to_target()
	elif shotgun_lookat_mouse:
		shotty.look_at(get_global_mouse_position())

func set_shotgun_free_rotate(value : bool):
	shotgun_lookat_mouse=value

func set_shotgun_target_look(value : bool):
	shotgun_lookat_target=value
	
func shotgun_unlock():
	if Input.is_action_just_released("sprint"):
		if target==null:
			set_shotgun_target_look(false)
		else:
			shotty_target=null

var shotty_target : Node2D

func shotgun_point_to_target():
	if shotty_target!=null:
		set_shotgun_target_look(true)
		shotty.look_at(shotty_target.global_position)
	elif target!=null:
		set_shotgun_target_look(true)
		shotty.look_at(target.global_position)
	else:
		set_shotgun_target_look(false)
		
func parry():
	
	if Input.is_action_just_pressed("parry") and state_machine.get_active_state()!=parry_success_state:
		parry_timer.start()
		parry_stance=true
		#set_state(state, States.PARRY)
		state_machine.dispatch(&"start_parry")
		pb_rot.disabled=false


	elif Input.is_action_just_released("parry") and state_machine.get_active_state()!=parry_success_state:
		parry_timer.stop()
		parry_stance=false
		state_machine.dispatch(&"return_to_idle")
		#anim_player.stop()
		
	
	#parry interactions
	if parry_stance==true:
		velocity.x=0
		velocity.y=0

func toggle_light():
	if Input.is_action_just_pressed("toggle_light"):
		flashlight.enabled = not flashlight.enabled
		
			
			
func call_audioplayer(sound : String) -> void:
	if SoundFx.sounds.has(sound):
		AudioStreamManager.play(SoundFx.sounds[sound])
	else:
		push_error("SOUND FILE MISSING")

## DODGE NEEDS WORK!!!
func dodge(input_axis):

	if Input.is_action_just_pressed("Dodge") and state_machine.get_active_state()!=dodge_state:
		if dodge_buffer.is_stopped():
			dodge_timer.start()
			if not is_on_floor():
				velocity.y=0
			if input_axis == 0:
				dodge_anim_run=dodge_anim
				if attack_state.get_active_state()!=attack_closer:
					pass
				else:
					velocity.x=0
				state_machine.dispatch(&"start_dodge")
			else:
				dodge_anim_run=dodge_anim+"_roll"
				state_machine.dispatch(&"start_dodge")
		else:
			if stagger.stagger>1:
				stagger.stagger-=1
				set_stagger()
			if dodge_state.dodge_chain==3:
				dodge_state.dodge_chain=1
			else:
				dodge_state.dodge_chain+=1
			state_machine.dispatch(&"start_dodge")
			#dodge_pos_start=pc.global_position.x
	
		
	
	
	if (dodge_timer.is_stopped()) and state_machine.get_previous_active_state()==dodge_back:
		
		#dodge_state=false
		dodge_timer.stop()
		#state=States.IDLE
		state_machine.dispatch(&"return_to_idle")
	

func _on_dodge_state_entered() -> void:
	stagger_recover.stop()
	dodging.emit()
	hurt_box.active=false
	set_collision_layer_value(2, false)

func _on_dodge_state_exited() -> void:
	stagger_recover.start()
	animated_sprite_2d.position.x=8.0
	hurt_box.active=true
	set_collision_layer_value(2, true)

func lockon():
	var target_dist : Vector2 = Vector2.ZERO
	
	if Input.is_action_just_pressed("lockon"):
		if combat_states.get_active_state()==locked:
			combat_states.dispatch(&"unlocking")
		enemies = get_tree().get_nodes_in_group("Enemy")
		if enemies.is_empty():
			return
		
		Events.unlock_from.emit()
		target = find_closest_enemy()
		
		

		if not target.on_screen.is_on_screen() or target.state_machine.get_active_state()==target.death:
			
			target=null
			set_shotgun_target_look(false)
		else:
			target.target_lock()
			shotty_target=target
			set_shotgun_target_look(true)
		
	if target == null:
		
		target_string_test="NONE"
		combat_states.dispatch(&"unlocking")
	else:
		
		target_dist=abs(global_position-target.global_position)
		if (target.state_machine.get_active_state()==target.death):
			combat_states.dispatch(&"unlocking")
			return
		
		combat_states.dispatch(&"locking_on")
		var direction_to_target : Vector2 = Vector2(target.position.x, target.position.y) - global_position
		
		var arc_vector = Vector2(position-Vector2(target.position)).normalized()
		target_direction = position.direction_to(target.position)
		
		#raycast from pointing away NEEDS WORK
		var dir_away_from_target : Vector2 = (Vector2(target.position.x, target.position.y) - target_testing.position)
		
		target_locking.look_at(dir_away_from_target)
		vector_away=-((target_testing.to_global(target_testing.target_position) - target_testing.to_global(Vector2.ZERO)).normalized())
		
		if state_machine.get_active_state()!=flip_state:
			target_dir()
			#if arc_vector<Vector2.RIGHT and Vector2.UP<arc_vector:
				#
				##"on right")
				#target_right = false
				#
			#elif arc_vector>Vector2.LEFT and Vector2.UP>arc_vector:
				##"on left")
				#target_right = true
			
func target_dir() -> void:
	if state_machine.get_active_state()==flip_state or \
	state_machine.get_active_state()==jump_state or \
	state_machine.get_active_state()==dodge_state:
		
		return
	else:
		if target!=null:
			if target.global_position.x>global_position.x:
				target_right = true
			else:
				target_right = false

func set_target_right(_value : bool) -> void:
	target_right=_value

func boss_died() -> void:
	target=null
	set_shotgun_target_look(false)
	combat_states.dispatch(&"unlocking")

func find_closest_enemy() -> Node2D:
	enemies.clear()
	
	enemies = get_tree().get_nodes_in_group("Enemy")
	
	if enemies.is_empty():
		return
		
	
	var closest_enemy = enemies[0]
	
	for enemy in enemies:
		if is_instance_valid(enemy):
			if (enemy.global_position.distance_to(global_position) < closest_enemy.global_position.distance_to(global_position))\
			and (enemy.state_machine.get_active_state()!=enemy.death):
				
				closest_enemy=enemy

			else:
				continue
		else:
			continue
			
	return closest_enemy
	
	
	
func get_target_info():
	if target==null:
		return
	else:
		target_size_x = target.get_width()
		target_size_y = target.get_height()
		target_top = target.global_position.y-(target_size_y/2-5)
		target_left_edge=target.global_position.x-(target_size_x/2)
		target_right_edge=target.global_position.x+(target_size_x/2)
		
		if target_size_y > collision_shape_2d.get_shape().size.y*1.5:
			high_target=true
		else:
			high_target=false

func locked_combat():
	if target==null:
		return
	else:
		var direction_to_target : Vector2 = Vector2(target.global_position.x, target.global_position.y) - global_position
		
		if target_right:
			var dist_to_edge=round(abs(global_position.x-target_right_edge))
			
		else:
			var dist_to_edge=round(abs(global_position.x-target_left_edge))
			
		#if abs(direction_to_target.x) >(50+target_size_x) or abs(direction_to_target.y)>(10+target_size_y):
			#pass
		#else:
			#if Input.is_action_just_pressed("jump") and Input.is_action_pressed("sprint"):
				##set_state(state, States.FLIP)
				#flip_over()

func set_next_room(value : String):
	next_room=value

func enter_door() -> void:
	if in_door_way:
		if Input.is_action_just_pressed("up"):
			store_player_data()
			
			if next_room=="RETURN":
				var temp : String = cur_room
				cur_room=prev_room
				prev_room=temp
			else:
				print_debug(global_position)
				Global.game_controller.set_prev_starting_point(global_position)
				assert(next_room!="RETURN")
				prev_room=cur_room
				cur_room=next_room
			if animated_door:
				Events.open_door.emit()
				await Events.door_opened
				Global.game_controller.change_2d_scene(next_room, false, false, entry_pos, "fade_to_black_quick", "fade_from_black_quick")
			else:
				
				Global.game_controller.change_2d_scene(next_room, false, false, entry_pos, "fade_to_black_quick", "fade_from_black_quick")
			#entry_pos=prev_starting_pos
			
	elif in_door_way_local:
		if Input.is_action_just_pressed("up"):
			if door_locked:
				local_door.locked_door_attempt()
			else:
				global_position=door_local_exit
			

func climb_stairs() -> void:
	if Input.is_action_pressed("down") and stairs_detected==false:
		set_collision_mask_value(20, false)
		#stairs_release=
	elif Input.is_action_just_released("down"):
		if stairs_detected:
			stairs_release=true
		else:
			set_collision_mask_value(20, true)

func drop_down():
	if Input.is_action_just_pressed("down") and not drop_down_platform_detected:
		set_collision_mask_value(27, false)
	elif Input.is_action_just_released("down"):
		set_collision_mask_value(27, true)

func _on_hazard_detector_area_entered(area):
	

	if health.health<=0:
		return
	elif area.is_in_group("hazard"):
		global_position=starting_position
		
		health.health -= 1
	#elif area.is_in_group("bullet"):
		#if state_machine.get_active_state()==dodge_state:
			#hit_stop.hit_stop(0.05, 0.1)
		#else:
			#return
	
	elif area.is_in_group("Enemy"):
		hit_stop.hit_stop(0.05, 0.05)
		#knockback.x = input_dir.x * knockback.x *0.25
		

func _on_interactable_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("door"):
		interact_prompt_player.play("Enter")
		
		if area.is_in_group("AnimatedDoor") or area.is_in_group("door"):
			
			if "local" in area:
				if area.local == true:
					local_door=area
					in_door_way_local=true
					door_local_exit=area.player_next_entry()
			else:
				in_door_way=true
			if area.locked:
				door_locked = true
			else: 
				door_locked = false
			if area.is_in_group("AnimatedDoor"):
				animated_door=true
	elif area.is_in_group("elevator_door"):
		interact_prompt_player.play("call_elevator")
		interact_ready=false
		elevator_door=true
	else:
		interact_prompt_player.play("Interact")
		interact_ready=true
		
func _on_interactable_detector_area_exited(area: Area2D) -> void:
	interact_prompt_player.play("RESET")
	in_door_way=false
	animated_door=false
	in_door_way_local=false
	door_locked=false
	if area.is_in_group("door"):
		if local_door !=null:
			local_door=null
		if area.is_in_group("AnimatedDoor"):
			in_door_way=false
			animated_door=false
			in_door_way_local=false
			door_locked=false
	else:
		interact_ready=false
	
func interact() -> void:
	if Input.is_action_just_pressed("Interact"):
		if interact_ready:
			Events.open_interact_menu.emit()
		elif elevator_door:
			Events.call_elevator.emit()


func open_interact_menu():
	interact_menu_open=true
	interact_prompt_player.play("RESET")
	interact_prompt_player.play("exit_popup")
	
func close_interact_menu():
	interact_menu_open=false

func get_state() -> String:
	return cur_state
func get_state_enum() -> LimboState:
	return state_machine.get_active_state()
#
func get_health() -> int:
	return health.health
func get_max_health() -> int:
	return health.max_health

func set_health() -> void:
	if Global.game_controller!=null:
		Global.game_controller.call_deferred("update_health",health.health)
	else:
		update_health.emit(health.health)
	#Global.game_controller.update_health(health.health)
func set_max_health() -> void:
	
	if Global.game_controller!=null:
		Global.game_controller.call_deferred("update_max_health",health.max_health)
	else:
		update_max_health.emit(health.max_health)
	#Global.game_controller.update_max_health(health.max_health)
func set_stagger() -> void:
	
	if Global.game_controller!=null:
		Global.game_controller.call_deferred("update_stagger", stagger.stagger)
	else:
		update_stagger.emit(stagger.stagger)
	#Global.game_controller.update_stagger(stagger.stagger)
func set_max_stagger() -> void:
	
	if Global.game_controller!=null:
		Global.game_controller.call_deferred("update_max_stagger", stagger.max_stagger)
	else:
		update_max_stagger.emit(stagger.max_stagger)
	#Global.game_controller.update_max_stagger(stagger.max_stagger)


func _on_health_health_depleted():
	state_machine.dispatch(&"die")



	
#knockbacks
#func _on_hurt_box_knockback(hitbox):
	##kb_dir=global_position.direction_to(hitbox.global_position)
	##"knockback")
	##kb_dir=round(kb_dir)
	##kb_dir.x, " ", knockback)

func _on_hurt_box_got_hit(_hitbox):
	set_health()
	if health.health<=0:
		return
	else:
		var hb_dir_right
		if not hit_timer.is_stopped():
			return
		if _hitbox.global_position.x-global_position.x>0 :
			hb_dir_right=true
		else:
			hb_dir_right=false
		if state_machine.get_active_state()==parry_state:
			return
		elif health.health<=0:
			return
		elif _hitbox.is_in_group("hitbox"):
			if hit_timer.is_stopped():
				AudioStreamManager.play(SoundFx.PUNCH_DESIGNED_HEAVY_12)
			player_hit.emitting=true
			player_hit.restart()
			#hurt_box_detect.disabled=true
			hurt_box_detect.call_deferred("set_disabled", true)
			hit_timer.start(0.2)
			stagger.stagger-=1
			#if state_machine.get_previous_active_state()!=flip_state and state_machine.get_previous_active_state()!=attack_state:
				##if parry_success_state.get_previous_active_state()==heavy_riposte:
					##if target_right:
						##knockback.x=400
					##else:
						##knockback.x=-400
				##else:
					##if hb_dir_right:
						##knockback.x=-15
					##else:
						##knockback.x=15
			hit.hit_anim="hit"
			state_machine.dispatch(&"got_hit")
			set_stagger()
			
		elif hitbox.is_in_group("heavy_hitbox"):
			#knockback.x = -400
			kb_dir=global_position.direction_to(_hitbox.global_position)
			#"knockback")
			kb_dir=round(kb_dir)
			#kb_dir.x, " ", knockback)
			#knockback.x = kb_dir.x * knockback.x
			velocity.y=movement_data.jump_velocity/2
			#velocity.x = movement_data.speed + knockback.x
			health.set_temporary_immortality(0.2)
		else:
			set_collision_mask_value(15, false)
			#knockback.x = -35
			kb_dir=global_position.direction_to(_hitbox.global_position)
			#"knockback")
			kb_dir=round(kb_dir)
			#kb_dir.x, " ", knockback)
			#knockback.x = kb_dir.x * knockback.x
			#velocity.y=movement_data.jump_velocity/2
			#velocity.x = movement_data.speed + knockback.x
			health.set_temporary_immortality(0.2)

func _on_hit_timer_timeout() -> void:
	hurt_box_detect.disabled=false
	if state_machine.get_previous_active_state()!=flip_state:
		state_machine.dispatch(&"return_to_idle")
	player_hit.emitting=false

func _on_hit_buffer_timeout() -> void:
	state_machine.dispatch(&"recovering")

func _on_parry_box_parried_success() -> void:
	state_machine.dispatch(&"parry_successful")
	clash_power.increase_clash()
	#clash_visual.emitting=true
	
	
func _on_collectible_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("Hearts"):
		increase_health()
		
func increase_health() -> void:
	health.health+=1
	set_health()

#Setting starting positions for level starts and checkpoints
func get_start_pos():
	return starting_position

func set_start_pos(checkpoint_position):
	starting_position=checkpoint_position



func _on_animation_player_animation_finished(anim_name):
	cutscene_handler.anim_count_up()
	if state_machine.get_active_state()==attack_state:
		hit_success=false
		hit_box.clash_active=false
		hb_collision.set_deferred("disabled", true)
		
		match anim_name:
			"Attack_Counter":
				counter_flag=false
				
				return
			"Attack_Chain":
				state_machine.dispatch(&"return_to_idle")
				sp_atk_chn=0
				atk_chain=0
				attack_timer.start(0.2)
				combo_state=ComboStates.SPC_ATK_BACK
				return
		#if atk_chain < 2:
			#atk_chain += 1
		#elif atk_chain >=2:
			#atk_chain = 0
			#attack_combo = "Attack"
			"Attack_Dash":
				attack_timer.start(.1)
				attack_timer.paused=false
				anim_player.play("landed")
				#attacking=false
				
			"shotgun_finish":
				attack_timer.start(0.1)
				attack_timer.paused=false
			"Heavy_Combo_1":
				#reset_combo_flag=true
				#attacking=false
				state_machine.dispatch(&"return_to_idle")
			"Heavy_Combo_2":
				reset_combo_flag=true
				#attacking=false
				state_machine.dispatch(&"return_to_idle")
			"Attack":
				attack_1.attack=light_attacks[1]
				
				charging_attack.attack=light_attacks[1]
				#attack_state_stack.push_front(attack_1)
				attack_timer.start(0.1)
				attack_timer.paused=false
			"Attack_2":
				attack_1.attack=light_attacks[2]
				
				charging_attack.attack=light_attacks[2]
				#attack_state_stack.push_front(attack_2)
				attack_timer.start(0.1)
				attack_timer.paused=false
			"Attack_3":
				attack_1.attack=light_attacks[0]
				
				charging_attack.attack=light_attacks[0]
				#attack_state_stack.push_front(attack_3)
				attack_timer.start(0.1)
				attack_timer.paused=false
				#reset_combo_flag=true
				#attacking=false
			_:
				attack_1.attack=light_attacks[0]
				attack_timer.start(0.1)
				attack_timer.paused=false
				heavy_attack_flag=false
				
		
				
				if state_machine.get_previous_active_state()==flip_state:
					state_machine.dispatch(&"jump_out")
	if anim_name=="landed":
		state_machine.dispatch(&"return_to_idle")
				
		#else:
			#state_machine.dispatch(&"return_to_idle")
		hit_buffer.stop()
		#hb_collision.disabled=true
		
	
	elif anim_name=="staggered":
		state_machine.dispatch(&"return_to_idle")
		stagger.stagger=stagger.get_max_stagger()
		set_stagger()
	#
	elif anim_name=="dodge_roll":
		
		velocity.x=0
		counter_box_collision.disabled=false
		set_collision_mask_value(15, true)
	elif anim_name=="dodge":
		
		counter_box_collision.disabled=false
	elif anim_name=="flip":
		
		anim_player.speed_scale=1
		state_machine.dispatch(&"landed")
	#
	#
	#
	#else:
		#pass

func _on_attack_timer_timeout():
	if Input.is_action_pressed("attack"):
		state_machine.dispatch(&"return_to_idle")
		return
	
	if state_machine.get_active_state()==parry_success_state or attack_state.get_active_state()==attack_closer:
		return
	atk_chain = 0
	attack_combo = "Attack"
	attack_1.attack = "Attack"
	
	if input_axis!=0:
		state_machine.dispatch(&"resume_walking")
	else:
		#return
		state_machine.dispatch(&"return_to_idle")
		#assert(state_machine.get_active_state()==idle)
	#attack_state.dispatch(&"reset_combo")
	attack_state.initial_state=attack_1
	sp_atk_chn = 0
	atk_1_resume=false
	atk_2_resume=false

func load_player_data():
	var file = FileAccess.open("user://player_data/stats/player_stats.txt", FileAccess.READ)
	#if file.file_exists("user://player_data/stats/player_stats.txt"):
		#while file.is_open():
			#var content = file.get_line()
			#var stat : String = content.get_slice(":", 0)
			#var stat_val : int = int(content.get_slice(":", 1))
			#
			#if stat != null:
				#match stat:
					#"health":
						#health.set_health(100)
					#"max_health":
						#health.set_max_health(100)
					#"max_stagger":
						#pass
					#"ammo":
						#ammo=stat_val
						#
			#if file.eof_reached():
				#break
		#file.close()
	health.health = GlobalSaveData.current_save.player.health
	health.max_health = GlobalSaveData.current_save.player.max_health
	stagger.stagger = GlobalSaveData.current_save.player.stagger
	stagger.max_stagger = GlobalSaveData.current_save.player.max_stagger
	
	
	#else:
		#print_debug("file not found")
		
	


func save_player_data():
	#var file = FileAccess.open("user://player_data/stats/player_stats.txt", FileAccess.READ_WRITE)
	#if file.file_exists("user://player_data/stats/player_stats.txt"):
		#var stat : String = str("health: ", health.get_health())
		#file.store_string(stat)
		#file.store_string("\n")
		#stat = str("max_health: ", health.get_max_health())
		#file.store_string(stat)
		#file.store_string("\n")
		#file.close()
	#else:
		#print_debug("file not found")
	GlobalSaveData.current_save.player.health=health.health
	GlobalSaveData.current_save.player.max_health=health.max_health
	GlobalSaveData.current_save.player.stagger=stagger.stagger
	GlobalSaveData.current_save.player.max_stagger=stagger.max_stagger
	GlobalSaveData.save_game()

func _on_parry_timer_timeout():
	parry_timer.stop()
	parry_stance=false
	#state=States.IDLE
	state_machine.dispatch(&"return_to_idle")
	
	#anim_player.stop()
	
func parry_success():
	parry_timer.stop()
	anim_player.play("Parry_Success")
	
	AudioStreamManager.play(parry_sfx)
	await anim_player.animation_finished
	#anim_player.stop()



func _on_hit_box_area_entered(_area):
	#print_debug(_area.get_groups())
	if _area.is_in_group("hurtbox"):
		hit_sfx()
	
	#if not hitbox.active:
		#return
	#else:
		#hit_buffer.start(1)
		##hitbox.active=false
		#hit_sound=hit1
		#AudioStreamManager.play(hit_sound)
		##hb_collision.disabled
		##hb_collision.set_deferred("disabled", true)
		#hit_fx.visible=true
		#hit_fx_player.stop()
		#hit_fx_player.play(hit_animation)

func hit_sfx() -> void:
	hit_buffer.start(1)
	hit_sound=hit1
	AudioStreamManager.play(hit_sound)
	hit_fx.visible=true
	hit_fx_player.stop()
	hit_fx_player.play(hit_animation)


func _on_hit_box_body_entered(body):
	if body.is_in_group("Enemy") and combat_states.get_active_state()==unlocked:
		Events.unlock_from.emit()
		target_string_test=str(body.name)
		target = body
		combat_state=CombatStates.LOCKED
		combat_states.dispatch(&"locking_on")
		if clash_power.clash_power>=1:
			stagger.stagger+=clash_power.clash_power
			clash_power.reset_clash()
			clash_timer.stop()
			if clash_power.clash_power==clash_power.clash_max:
				hit_stop.hit_stop(.3,.5)
			set_stagger()
	
	
func flip_over():
	if combat_states.get_active_state()==unlocked:
		return
	else:
		var direction_to_target : Vector2 = Vector2(target.position.x, target.position.y) - global_position
		var _dist_to_target_x = abs(direction_to_target.x) >(50+target_size_x) or abs(direction_to_target.y)>(10+target_size_y)
		if state_machine.get_active_state()==dodge_state:
			if Input.is_action_just_pressed("jump"):
				flip_speed=movement_data.speed * 80
				state_machine.dispatch(&"start_flip")
				flip.emit()
	#state=States.FLIP
#
func flipping(delta):
	pass

		
	if not flipped_over:
		pass
		
	else:
		pass
		
			
func _on_flip_state_entered() -> void:
	#	variables set and declared
	print_debug("entering flip")
	target_pos_y=(target.global_position.y)
	var pos_above_y=target.global_position.y-global_position.y
	target_pos_x=(target.global_position.x)
	var pos_above_x=target.global_position.x-global_position.x
	flip_buffer.start()


func _on_flip_state_updated(delta: float) -> void:
	if is_on_wall():
		wall_hold = true
		state_machine.dispatch(&"hit_wall")
		hit_stop.end_hit_stop()
	#elif is_on_floor():
		#state_machine.dispatch(&"landing")
		#hit_stop.end_hit_stop()
	elif Input.is_action_just_pressed("jump") and flip_buffer.is_stopped():
		jump_out(30)
		state_machine.dispatch(&"jump_out")
	elif Input.is_action_just_pressed("attack"):
		jump_out(15)
		state_machine.dispatch(&"flip_attack")
	else:
		health.immortality=true
		hurt_box_detect.disabled=true
		#position.y, " ",target_size_y+target.position.y)
		#print_debug(global_position)
		#print_debug((target_left_edge-15)," , ",(target_top-25))
		if global_position.y>target_top-15 and not high_target:
			if target_right:
				#print_debug(global_position)
				#print_debug((target_left_edge-15)," , ",(target_top-25))
				if global_position<Vector2((target_left_edge-15),(target_top-25)):
					global_position=lerp(global_position, Vector2((target_left_edge-5),(target_top-40)), delta*3)
				else:
					velocity.y=movement_data.jump_velocity
			else:
				if global_position>Vector2((target_right_edge+15),(target_top-25)):
					global_position=lerp(global_position, Vector2((target_right_edge+5),(target_top-40)), delta*3)
				else:
					velocity.y=movement_data.jump_velocity
							
		elif global_position.y>(high_target_jump_height-15) and high_target:
			if target_right:
				if global_position<Vector2((target_left_edge-15),(high_target_jump_height)):
					global_position=lerp(global_position, Vector2((target_left_edge-5),(high_target_jump_height*0.7)), delta*3)
				else:
					wall_hold = true
					state_machine.dispatch(&"hit_wall")
					#velocity.y=movement_data.jump_velocity
			else:
				
				if global_position>Vector2((target_right_edge+15),(high_target_jump_height)):
					global_position=lerp(global_position, Vector2((target_right_edge+5),(high_target_jump_height*0.7)), delta*3)
				else:
					wall_hold = true
					state_machine.dispatch(&"hit_wall")
					#velocity.y=movement_data.jump_velocity

		else:
			#flipped_over=true
			#hit_stop.hit_stop(.2, .5)
			state_machine.dispatch(&"flipped_over")

func _on_flip_end_state_entered() -> void:
	#print_debug("flipped over")
	hit_stop.hit_stop(.2, .5)


func _on_flip_end_state_updated(delta: float) -> void:
	if is_on_wall():
		wall_hold = true
		state_machine.dispatch(&"hit_wall")
		hit_stop.end_hit_stop()
	elif is_on_floor():
		state_machine.dispatch(&"landing")
		hit_stop.end_hit_stop()
	elif Input.is_action_just_pressed("jump"):
		jump_out(30)
		state_machine.dispatch(&"jump_out")
	elif Input.is_action_just_pressed("attack"):
		jump_out(15)
		state_machine.dispatch(&"flip_attack")
	else:
		health.immortality=false
		hurt_box_detect.disabled=false
		flipped_over=true
		if not high_target:
			
			if not flip_state.flipping_right:
				movement = target_direction.rotated(CLOCKWISE)
				
				#"flip_right")
			else:
				movement = target_direction.rotated(COUNTER_CLOCKWISE)
				#"flip_left"
			if global_position.y<target_top:
				velocity = movement * flip_speed * delta
				
			else:
				velocity.y += gravity * movement_data.gravity_scale * delta
		else:
			#hit_stop.hit_stop(.1, .5)
			jump_out_timer.start(0.05)
			velocity.y=0

func _on_jump_out_timer_timeout():
	jump_out(200)
	



func atk_state_debug():
	match combo_state:
		ComboStates.ATK_1:
			atk_state="AKT_1"
		ComboStates.SPC_ATK_BACK:
			atk_state="SPC_ATK_BACK"
			

func _on_counter_box_area_entered(area):
	
		
	if area.is_in_group("hitbox"):
		pass
		#print_debug("enemy dodge")
		#state_machine.dispatch(&"dodge_successful")
		#clash_power.clash_power += 1
		
		
	clash_power.increase_clash()
	#clash_visual.emitting=true
	clash_timer.start()
		
func _on_counter_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("bullet"):
		if state_machine.get_active_state()!=dodge_state:
			return
		else:
			hit_stop.hit_stop(0.05, 0.5)
			body.bullet_dodged()
			counter_flag = true
			counter_timer.start()
			clash_power.increase_clash()
			clash_timer.start()
	elif body.is_in_group("missile"):
		body.stop_tracking()

func _on_counter_timer_timeout():
	counter_flag = false


func _on_hazard_detector_body_entered(body):
	if body.is_in_group("Enemy"):
		if (position.y-body.position.y)<0:
			target_below=true
		else:
			print_debug("enemy above")


func _on_hazard_detector_body_exited(body):
	if body.is_in_group("Enemy"):
		#"leaving enemy")
		target_below=false


func _on_animation_player_animation_started(anim_name):
	if state_machine.get_active_state()==attack_state:
		#hit_box.active=true
		hb_collision.set_deferred("disabled", false)
		match anim_name:
			"Attack":
				heavy_attack_1.attack=heavy_attacks[0]
			"Attack_2":
				heavy_attack_1.attack=heavy_attacks[1]
			"Attack_3":
				heavy_attack_1.attack=heavy_attacks[2]
					

	if anim_name=="Attack_Chain":
		if face_right:
			forward_thrust.x=200
		else:
			forward_thrust.x=-200
		velocity.x = forward_thrust.x
	elif anim_name=="shotgun_attack_fast":
		AudioStreamManager.play(shotgun_fire)
		if combo_state==ComboStates.SPC_ATK_BACK:
			knockback.y=-100
			if face_right:
				knockback.x=-250
			else:
				knockback.x=250
			velocity.x = knockback.x
			velocity.y = knockback.y
	elif anim_name=="shotgun_attack":
		vel_y=velocity.y
		#s_atk=true
	elif anim_name=="shotgun_finish":
		print_debug("heavy finisher")


func _on_hurt_box_received_damage(damage: int) -> void:
	hit_box.clash_active=false
	if health.health<=0:
		return
	hit_stop.hit_stop(0.05, 0.1)
	Events.camera_shake.emit(2,20)
	if state_machine.get_active_state()==flip_state:
		hit.hit_anim="knocked_back"
		state_machine.dispatch(&"got_hit")
	elif state_machine.get_active_state()==parry_success_state:
		hit.hit_anim="knocked_back"
		state_machine.dispatch(&"got_hit")
		stagger.stagger-=3
		
	set_stagger()
	set_health()
	stagger_recover.start()
	
func _on_stagger_recover_timeout() -> void:
	if stagger.stagger<stagger.max_stagger:
		stagger.stagger+=1
		set_stagger()

func _on_hurt_box_bullet_hit(_damage: int) -> void:
	if state_machine.get_active_state()==dodge_state:
		hit_stop.hit_stop(0.5, 1)
	else:
		if health.health<=0:
			return
		Events.camera_shake.emit(2,20)
	#_new_health = health.health-_damage
	#health.health=_new_health
	#print_debug(health.health)
	#if health.health!=_new_health:
		#print_debug("sum ting wong")
	#set_health()
	

func _on_stagger_staggered() -> void:
	knockback.x=0
	velocity=Vector2.ZERO
	state_machine.dispatch(&"got_staggered")
	hit_stop.hit_stop(0.7, 1)
	Events.camera_shake.emit(2,15)
	
func _on_hit_box_parried() -> void:
	anim_player.play("parried")
	#hb_collision.disabled=true
	if target_right:
		knockback.x=-40
	else:
		knockback.x=40
	Events.enemy_parried.emit()
	
	#velocity.x = movement_data.speed + knockback.x

func _on_hit_box_clash_interrupt(_launch: float, _knockback: float, _impact_dir_right: bool, _damage: int) -> void:
	hit.hit_anim="knocked_back"
	if _impact_dir_right:
		knockback.x=-_knockback
	else: 
		knockback.x=_knockback
	velocity.y=-_launch
	state_machine.dispatch(&"interrupt_knockback")
	stagger.stagger-= _damage
	attacking=false
		
func _on_hit_stop_hit_stop_finished() -> void:
	if not qte_handler.actor_control_active:
		no_input_qte.emit()
	else:
		pass



func _on_idle_entered() -> void:
	anim_player.play("idle")
	attack_timer.paused=false


func _on_state_machine_active_state_changed(current: LimboState, _previous: LimboState) -> void:
	
	if current==dodge_state:
		
		if attack_state.get_active_state()==attack_1:
			atk_1_resume=true
		elif attack_state.get_active_state()==attack_2:
			atk_2_resume=true
	#FOR DEBUGGING TO BE REMOVED
	match current:
		attack_state:
			cur_state="ATTACK"
		special_attack:
			cur_state="SPECIAL_ATTACK"
		idle:
			cur_state="IDLE"
		walking:
			cur_state="WALKING"
		jumping:
			cur_state="JUMP"
		dodge_state:
			cur_state="DODGE"
		wall_stick:
			cur_state="WALL STICK"
		sprint:
			cur_state = "SPRINTING"
		parry_state:
			cur_state = "PARRY"
		flip_state:
			cur_state = "FLIP"
		parry_success_state:
			cur_state= "PARRY SUCCESS"
		recovery:
			if _previous==hit:
				recovery.recover_anim="hit_recover"
			elif _previous==staggered:
				recovery.recover_anim="stagger_recover"


func _on_attack_state_active_state_changed(current: LimboState, previous: LimboState) -> void:
	if current==special_combo:
		if previous==attack_1:
			atk_2_resume=false
			atk_1_resume=true
		elif previous==attack_2:
			atk_2_resume=true
			atk_1_resume=false
		
	if previous==special_combo:
		atk_1_resume=false
		atk_2_resume=false
	
	if current in [attack_1, attack_2, attack_3]:
		hitbox.stagger_damage=false
	elif current in [heavy_attack_1, heavy_attack_2]:
		hitbox.stagger_damage=true



func _on_combat_states_active_state_changed(current: LimboState, previous: LimboState) -> void:
	pass


func _on_clash_timer_timeout() -> void:
	clash_power.reset_clash()
	#clash_visual.emitting=false
	
	
#func _on_clash_power_increase_aura(value : int) -> void:
	#clash_aura_fx.visible=true
	#if not clash_aura_player.is_playing():
		#clash_aura_player.play("clash_aura")
	#clash_timer.start()
	#hit_box.set_damage(hit_box.damage+value)
	#match value:
		#1:
			#clash_aura_player.speed_scale=0.25
			#clash_aura_fx.self_modulate.a=0.2
		#2:
			#clash_aura_player.speed_scale=0.5
			#clash_aura_fx.self_modulate.a=0.4
		#3:
			#clash_aura_player.speed_scale=1
			#clash_aura_fx.self_modulate.a=0.6
		#4:
			#clash_aura_player.speed_scale=1.5
			#clash_aura_fx.self_modulate.a=0.8
		#5:
			#clash_aura_player.speed_scale=2
			#clash_aura_fx.self_modulate.a=1
		#_:
			#pass
	#
#func _on_clash_power_decrease_aura(value: int) -> void:
	#hit_box.set_damage(hit_box.damage+value)
	#match value:
		#0:
			#clash_power.reset_clash()
			#clash_aura_player.stop()
		#1:
			#clash_aura_player.speed_scale=0.25
			#clash_aura_fx.self_modulate.a=0.2
		#2:
			#clash_aura_player.speed_scale=0.5
			#clash_aura_fx.self_modulate.a=0.4
		#3:
			#clash_aura_player.speed_scale=1
			#clash_aura_fx.self_modulate.a=0.6
		#4:
			#clash_aura_player.speed_scale=1.5
			#clash_aura_fx.self_modulate.a=0.8
		#5:
			#clash_aura_player.speed_scale=2
			#clash_aura_fx.self_modulate.a=1
		#_:
			#pass
	
func _on_clash_power_aura_change(value: int) -> void:
	
	if value >=1:
		clash_aura_fx.visible=true
		if not clash_aura_player.is_playing():
			clash_aura_player.play("clash_aura")
		clash_timer.start()
	hit_box.set_damage(hit_box.damage+value)

	match value:
		0:
			clash_power.reset_clash()
			clash_aura_player.stop()
		1:
			clash_aura_player.speed_scale=0.25
			clash_aura_fx.self_modulate.a=0.2
		2:
			clash_aura_player.speed_scale=0.5
			clash_aura_fx.self_modulate.a=0.4
		3:
			clash_aura_player.speed_scale=1
			clash_aura_fx.self_modulate.a=0.6
		4:
			clash_aura_player.speed_scale=1.5
			clash_aura_fx.self_modulate.a=0.8
		5:
			clash_aura_player.speed_scale=2
			clash_aura_fx.self_modulate.a=1
		_:
			pass
	
	
	
#################
#Clash Functions#
#################
func _on_clash_power_aura_reset() -> void:
	clash_aura_player.stop()
	clash_aura_fx.visible=false
	hit_box.set_damage(1)

func _on_stars_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("dropdownplatform"):
		drop_down_platform_detected=true
	else:
		stairs_detected=true

func _on_stars_detector_body_exited(body: Node2D) -> void:
	if body.is_in_group("dropdownplatform"):
		drop_down_platform_detected=false
	else:
		stairs_detected=false
		set_collision_mask_value(20, true)
		
		
####################
#Cutscene Functions#
####################
#
#
func set_path_speed(speed : int) -> void:
	path_speed=speed
	#print_debug(path_speed)
func start_path(speed : int):
	set_path_start(true)
	set_path_speed(speed)
	#print_debug(speed)
func set_path_start(value) -> void:
	path_start=value


func play_cutscene(_cutscene : String):
	anim_player.stop()
	cutscene_sub_player.play(_cutscene)




###############
#QTE Functions#
###############

func qte_input():
	if Input.is_action_just_pressed("attack"):
		attack_qte.emit()
		hit_stop.end_hit_stop()
	elif Input.is_action_just_pressed("Dodge"):
		dodge_qte.emit()
		hit_stop.end_hit_stop()
	elif Input.is_action_just_pressed("parry"):
		block_qte.emit()
		hit_stop.end_hit_stop()
	elif Input.is_action_just_pressed("special_attack"):
		special_atk_qte.emit()
		hit_stop.end_hit_stop()
	else:
		pass


####################################################
#Saving and loading player data upon enter new room#
####################################################

func init_player_data():
	health.health=GlobalSaveData.current_save["player"]["health"]
	health.max_health=GlobalSaveData.current_save["player"]["max_health"]
	stagger.stagger=GlobalSaveData.current_save["player"]["stagger"]
	stagger.max_stagger=GlobalSaveData.current_save["player"]["max_stagger"]

func store_player_data():
	GlobalSaveData.current_save["player"]["health"]=health.health
	GlobalSaveData.current_save["player"]["max_health"]=health.max_health
	GlobalSaveData.current_save["player"]["stagger"]=stagger.stagger
	GlobalSaveData.current_save["player"]["max_stagger"]=stagger.max_stagger


func _on_texture_button_pressed() -> void:
	interact_menu_open=false
	Events.close_interact_menu.emit()


func _on_health_health_changed(diff: int) -> void:
	pass # Replace with function body.


func _on_death_entered() -> void:
	anim_player.play("death")
	hit_stop.hit_stop(0.3, 3)
	Events.player_death.emit()


func _on_death_updated(delta: float) -> void:
	#hit_stop.end_hit_stop()
	await anim_player.animation_finished
	state_machine.dispatch(&"dead")


func _on_dead_entered() -> void:
	Events.game_over.emit()

func reloaded() -> void:
	anim_player.stop()
	state_machine.change_active_state(idle)

func _on_health_max_health_changed(diff: int) -> void:
	pass # Replace with function body.


func _on_jump_state_updated(delta: float) -> void:
	pass
	#assert(velocity.y!=0.0)
	#if state_machine.get_previous_active_state()==wall_stick:
		#assert(velocity.x!=0)


func _on_jump_state_entered() -> void:
	var _jump_vel_x=30
	var _jump_vel_y=50
	velocity.y = movement_data.jump_velocity/2



func _on_attack_state_exited() -> void:
	set_shotgun_free_rotate(true)
	hb_collision.set_deferred("disabled", true)


func _on_stagger_stagger_decreased(diff: int) -> void:
	set_stagger()


func _on_clash_up() -> void:
	clash_power.increase_clash()


	
func _on_knockback(_launch_strength : float, _knockback_strength : float, impact_dir_right : bool) -> void:
	if stagger.stagger>0:
		_launch_strength=roundf(_launch_strength/stagger.stagger)
		_knockback_strength=roundf(_knockback_strength/stagger.stagger)
	if impact_dir_right:
		_knockback_strength*=-1
	knockback.x=_knockback_strength*(face_dir)
	if round(_launch_strength)!=0:
		velocity.y= -(_launch_strength)
	###### TBD LATTER #####
	if _launch_strength!=0:
		print_debug("team rockets jerking off again")

func _on_hit_box_clashed() -> void:
	hb_collision.set_deferred("disabled", true)
	hit_box.active=false
	clash_power.increase_clash()
	if unlocked:
		lockon()
	#hit_fx_player.play("clashed")
	hit_animation="clashed"
	hit_sfx()
	var _current_atk : String
	if heavy_attacking:
		_current_atk = heavy_attack_1.attack
	else:
		_current_atk = attack_1.attack
	var _atk_clash_anim : String = _current_atk+"_connect"
	var _atk_clash_anim_end : String = _current_atk+"_end"
	assert(anim_player.has_animation(_current_atk))
	var _atk_connect := anim_player.get_animation(_current_atk).get_marker_time(_atk_clash_anim)
	if attack_state.get_active_state()==charging_attack:
		charge_timer.stop()
		charge_timer.timeout.emit()
		
	
	hit_box.active=false
	


func _on_animation_player_animation_changed(old_name: StringName, new_name: StringName) -> void:
	pass

func _on_animation_player_current_animation_changed(name: StringName) -> void:
	#pass
	if name == "Walk":
		print_debug("where")


func _on_locked_updated(delta: float) -> void:
	target_dir()


func _on_hit_box_hit_success() -> void:
	clash_power.reset_clash()
