class_name camera_position

extends Node2D

@export_category("Camera Shake")
@export var rand_strength :  float = 2 : set=set_rand_strength, get=get_rand_strength
@export var shake_fade : float = 20
@onready var camera_2d: Camera2D = $Camera2D

@export_category("Camera Positions/Zoom")
##Higher values = More zoomed in
@export var camera_zoom : float = 1.0
##Keeps camera from moving via character
@export var stationary : bool = false
##Offsets camera from parent node
@export var offset : Vector2 = Vector2.ZERO
##Camera movement speed
@export var camera_speed_default = 5.0

@export_category("Arena")
##Determines if arena is a boss arena or not
@export var boss_active := false : set = set_boss_active
@onready var player := get_tree().get_first_node_in_group("player")
##Connected boss, if available
@export var boss : Node2D
##Camera movement speed
@export var camera_speed := 5.0
##Limit of how far camera will move on x-axix
@export var x_edge_limit := 175.0
##Limit of how far camera will move on y-axix
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
	Events.boss_died.connect(boss_died)
	camera_2d.zoom*=camera_zoom
	zoom_default=camera_2d.zoom
	camera_2d.position_smoothing_speed=camera_speed_default
	
func _process(delta: float) -> void:
	
	camera_2d.offset=offset
	
	if shake_strength>0:
		shake_strength = lerpf(shake_strength, 0, shake_fade*delta)
		
		camera_2d.offset+=randomOffset()

	if boss_active and not stationary:
		boss_arena_camera()

func camera_shake_fixed():
	shake_strength=rand_strength
	
func camera_shake(str : float, fade : float) -> void:
	camera_offset_reset()
	shake_strength=str
	shake_fade=fade

func camera_offset_reset() -> void:
	camera_2d.offset=offset

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
	
	###Get all arena marked entities and player
	var _all_entities := get_tree().get_nodes_in_group("Enemy_arena")
	_all_entities.push_front(player)
	var _entity_positions : Array[Vector2]
	
	###Get all positions of entities
	for entity in range(_all_entities.size()-1, -1, -1):
		_entity_positions.push_back(_all_entities[entity].global_position)
	
	###Find Center point position between all entities in arena
	var _camera_pos :=  Vector2.ZERO
	for i in range(_entity_positions.size()-1, -1, -1):
		_camera_pos+=_entity_positions[i]
	_camera_pos=_camera_pos/_entity_positions.size()
	
	###Clamp and remap camera off y to arena edge
	_camera_pos.y=remap(clampf(abs(_camera_pos.y), 0, y_edge_limit),0,y_edge_limit, y_offset_limit.x, y_offset_limit.x)
	
	###Get Distance between player and farthest enemy
	var _furthest = find_furthest_enemy()
	var _character_distance=clampf(abs(player.global_position.x - _furthest.global_position.x), 0, x_edge_limit)
	
	###Map zoom range to camera offset
	var _camera_zoom=clampf(remap(_character_distance, x_edge_limit, 0, 0.75, zoom_limit), 0.5, zoom_limit)
	
	camera_2d.offset=lerp(camera_2d.offset, Vector2(0, _camera_pos.y), 0.1)
	camera_2d.zoom=lerp(camera_2d.zoom, Vector2(_camera_zoom, _camera_zoom), 0.1)
	global_position.x=lerpf(global_position.x, _camera_pos.x, 0.1)
	
func set_boss_active(_value : bool) -> void:
	boss_active=_value

func boss_died() -> void:
	set_boss_active(false)

func setup_arena_camera(_camera_speed: float = 5.0,\
 _x_edge_limit: float = 175.0, _y_edge_limit: float = 100.0,\
 _x_offset_limit: Vector2 = Vector2(0.0, 200.0), _y_offset_limit: Vector2 = Vector2(-20.0, -60.0), \
_zoom_limit: float = 2.0) -> void:
	camera_speed=_camera_speed
	x_edge_limit=_x_edge_limit
	y_edge_limit=_y_edge_limit
	x_offset_limit=_x_offset_limit
	y_offset_limit=_y_offset_limit
	zoom_limit=_zoom_limit

func find_boss() -> void:
	boss = get_tree().get_first_node_in_group("Boss")

func reset_camera() -> void:
	camera_2d.offset=offset
	camera_2d.zoom=zoom_default
	camera_2d.position_smoothing_speed=camera_speed_default

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
