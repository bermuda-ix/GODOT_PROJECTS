extends Node2D
class_name Turret

signal shoot_bullet()

var player_found : bool = false
var player : PlayerEntity = null
#@onready var turret_body = $TurretBody
@onready var player_tracker = $PlayerTracking
@onready var shoot_timer = $ShootTimer
var direction_to_player : Vector2 

var pos = position

#@export var bullet = preload("res://Component/wave_projectile.tscn")

@export var ranged_mode : bool = true : set = set_ranged_mode, get = get_ranged_mode
var dist_to_player : get = get_dist_to_player

# Called when the node enters the scene tree for the first time.
func _ready():
	setup()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	track_player()
	#rotate_bullet()
	shoot()
	pos=position
	
	
func setup():
	player = get_tree().get_first_node_in_group("player")
	shoot_timer.start()
	#turret_body.visible=false


func track_player():
	if player == null:
		return
	
	player_tracker.target_position = to_local(player.position)
	
	direction_to_player = player.position - pos
	#turret_body.rotation=direction_to_player.angle()
	dist_to_player = direction_to_player
	
func rotate_bullet():
	rotate(player_tracker.rotation)
	
func shoot():
	if ranged_mode==true:
		if shoot_timer.is_stopped():
			#print(direction_to_player)
			shoot_timer.start()
			#print("shoot")
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

func get_dist_to_player():
	return dist_to_player
