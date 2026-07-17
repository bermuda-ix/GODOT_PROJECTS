@tool
extends Node2D
class_name Turret

signal shoot_bullet()

var player_found : bool = false
var player : PlayerEntity = null
#@onready var turret_body = $TurretBody
@onready var player_tracker = $PlayerTracking
@onready var shoot_timer : Timer = $ShootTimer
var direction_to_player : Vector2 

var pos = position

#@export var bullet = preload("res://Component/wave_projectile.tscn")

@export var ranged_mode : bool = true : set = set_ranged_mode, get = get_ranged_mode
@export var multi_shot : bool = false : set = set_multi_shot, get = get_multi_shot
@export var ammo_count : int
@export var max_ammo : int
@export var infinite_ammo : bool
@export var slow_track : bool = false
@export var shoot_speed : float = 0.2
@export var instant_tracking := false
##Faster tracking closer to 1.0
@export var tracking_speed := 0.4

var dist_to_player : get = get_dist_to_player

func _validate_property(property: Dictionary) -> void:
	if property.name == "tracking_speed" and instant_tracking:
		property.usage |= PROPERTY_USAGE_READ_ONLY

# Called when the node enters the scene tree for the first time.
func _ready():
	setup(shoot_speed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player_tracker!=null:
		track_player()
	#rotate_bullet()
	#shoot(2)
	pos=position
	
	
func setup(time : float):
	player = get_tree().get_first_node_in_group("player")
	if shoot_timer!=null:
		shoot_timer.start(time)
	#turret_body.visible=false
		shoot_timer.paused=false


func track_player():
	if slow_track:
		return
	else:
		
		if player == null or player.flipped_over:
			return
		
		if instant_tracking:
			player_tracker.target_position = to_local(player.global_position)
		else:
			player_tracker.target_position = lerp(player_tracker.target_position, to_local(player.global_position), 0.4)
		
		direction_to_player = player.global_position - pos
		#turret_body.rotation=direction_to_player.angle()
		dist_to_player = direction_to_player
	
func rotate_bullet():
	rotate(player_tracker.rotation)
	
func shoot():
	if ranged_mode==true:
		#print_debug("begin shoot")
		if multi_shot:
			shoot_bullet.emit()
		
		else:
			if shoot_timer.is_stopped():
				#print_debug(direction_to_player)
				shoot_timer.start()
				#print_debug("shoot")
				shoot_bullet.emit()
				
				
				#var bullet_inst = bullet.instantiate()
				#bullet_inst.dir = (player_tracking.target_position).normalized()
				#bullet_inst.spawnPos = pos
				#bullet_inst.spawnRot = turret_body.rotation
				#add_child(bullet_inst)
	
	
func set_ranged_mode(value: bool):
	ranged_mode=value

func get_ranged_mode()->bool:
	return ranged_mode

func set_multi_shot(value: bool):
	multi_shot=value

func get_multi_shot()->bool:
	return multi_shot

func get_dist_to_player():
	return dist_to_player
