class_name camera_position

extends Node2D

@export_category("Camera Shake")
@export var rand_strength :  float = 2 : set=set_rand_strength, get=get_rand_strength
@export var shake_fade : float = 20
@onready var camera_2d: Camera2D = $Camera2D

@export_category("Camera Positions/Zoom")
@export var camera_zoom : float = 1.0
@export var stationary : bool = false
@export var offset : Vector2 = Vector2.ZERO

@export_category("Arena")
@export var boss_active := false : set = set_boss_active
@onready var player := get_tree().get_first_node_in_group("player")
@export var boss : Node2D
@export var camera_speed := 5.0
@export var x_edge_limit := 175.0
@export var y_edge_limit := 100.0
@export var x_offset_limit := Vector2(0.0, 200.0)
@export var y_offset_limit := Vector2(-20.0, -60.0)
@export var zoom_limit := 2.0

var zoom_default : Vector2

var rng = RandomNumberGenerator.new()

var shake_strength : float = 0

func _ready() -> void:
	Events.camera_shake.connect(camera_shake)
	Events.player_death.connect(player_death)
	Events.reload_level_checkpoint.connect(reset_zoom)
	camera_2d.zoom*=camera_zoom
	zoom_default=camera_2d.zoom
	
func _process(delta: float) -> void:
	
	camera_2d.offset=offset
	
	if shake_strength>0:
		shake_strength = lerpf(shake_strength, 0, shake_fade*delta)
		
		camera_2d.offset+=randomOffset()

	if boss_active:
		if boss == null:
			return
		else:
			boss_arena_camera()

func camera_shake_fixed():
	shake_strength=rand_strength
	
func camera_shake(str : float, fade : float):
	shake_strength=str
	shake_fade=fade
	
func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))

func get_rand_strength() -> float:
	return rand_strength
	
func set_rand_strength(value : float):
	rand_strength=value


func set_cam_smooth(value: bool, _speed: float = 3.0) -> void:
	camera_2d.position_smoothing_enabled=value
	camera_2d.position_smoothing_speed=_speed

func dramatic_zoom(_zoom_value : float) -> void:
	camera_2d.zoom*=_zoom_value
	
func player_death() -> void:
	dramatic_zoom(2)

func reset_zoom() -> void:
	camera_2d.zoom=zoom_default

func boss_arena_setup(_boss : Node2D) -> void:
	assert(player!=null)
	if boss==null:
		boss=_boss
	
func boss_arena_camera() -> void:
	#var _camera_pos_x
	#if player.global_position.x>boss.global_position.x:
		#_camera_pos_x= boss.global_position.x + (player.global_position.x-boss.global_position.x)/2
	#else:
		#_camera_pos_x= player.global_position.x + (boss.global_position.x-player.global_position.x)/2
		#
	var _all_entities := get_tree().get_nodes_in_group("Enemy_arena")
	_all_entities.push_front(player)
	var _entity_positions : Array[Vector2]
	
	for entity in range(_all_entities.size()-1, -1, -1):
		_entity_positions.push_back(_all_entities[entity].global_position)
		
	#var _camera_pos_x = (player.global_position.x-boss.global_position.x)/2
	#var _camera_pos_x : int=0
	#for x in range(_entity_positions.size()-1, -1, -1):
		#_camera_pos_x+=_entity_positions[x].x
	#_camera_pos_x=_camera_pos_x/_entity_positions.size()
	#
	#var _camera_pos_y
	#for y in range(_entity_positions.size()-1, -1, -1):
		#_camera_pos_y+=_entity_positions[y].y
	#_camera_pos_y=_camera_pos_y/_entity_positions.size()
	
	var _camera_pos :=  Vector2.ZERO
	for i in range(_entity_positions.size()-1, -1, 0):
		print_debug(_entity_positions[i])
		_camera_pos+=_entity_positions[i]
	_camera_pos=_camera_pos/_entity_positions.size()
	
	
	_camera_pos.y=remap(clampf(abs(_camera_pos.y), 0, y_edge_limit),0,y_edge_limit, y_offset_limit.x, y_offset_limit.x)
	
	###Get Distance between player and farthest enemy
	var _furthest = find_furthest_enemy()
	var _character_distance=clampf(abs(player.global_position.x - _furthest.global_position.x), 0, x_edge_limit)
	
	var _camera_zoom=clampf(remap(_character_distance, x_edge_limit, 0, 0.5, zoom_limit), 0.5, zoom_limit)
	
	camera_2d.offset=Vector2(_camera_pos.x, _camera_pos.y)
	camera_2d.zoom=Vector2(_camera_zoom, _camera_zoom)
	
func set_boss_active(_value : bool) -> void:
	boss_active=_value

func find_boss() -> void:
	boss = get_tree().get_first_node_in_group("Boss")



func find_furthest_enemy() -> Node2D:

	var enemies = get_tree().get_nodes_in_group("Enemy")
	
	if enemies.is_empty():
		return
		
	
	var furthest_enemy = enemies[0]
	
	for enemy in enemies:
		if is_instance_valid(enemy):
			if (enemy.global_position.distance_to(global_position) > furthest_enemy.global_position.distance_to(global_position))\
			and (enemy.state_machine.get_active_state()!=enemy.death):
				
				furthest_enemy=enemy

			else:
				continue
		else:
			continue
			
	return furthest_enemy
