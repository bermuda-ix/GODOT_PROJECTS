class_name FlyingMovementHandler extends Node

@export var animated_sprite_2d : AnimatedSprite2D
@export var hit_box : HitBox = null
@export var hurt_box : HurtBox = null
@export var bullet_detection : BulletDetection = null
@export var attack_range : AttackRange = null
@export var actor : Node2D
@export var chasing_state : Chasing = null
@export var nav_agent : NavigationAgent2D
@export var vision_handler : VisionHandler = null
@onready var player : PlayerEntity = null

@onready var dir := Vector2.RIGHT

@export_category("Active")
@export var active := true

@export_category("Movement Stats")
@export var max_speed : int = 40
@export var cur_speed : int = 40
@export var distance : int = 100
@export var buffer_zone : int = 10
@export var height : int = 40
@export var agility : float = 1.5

func set_cur_speed(_value ) -> void:
	cur_speed=_value
	if _value==40:
		pass

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	


func _physics_process(delta: float) -> void:
	face_player()
	var dist_to_player=abs(actor.global_position-player.global_position)
	
	var actor_dis= actor.global_position.distance_to(player.global_position)
	
	if actor_dis>(distance-buffer_zone)\
	and actor_dis<=(distance+buffer_zone):
		print_debug(actor_dis)
		print_debug(distance+buffer_zone,", ",distance-buffer_zone)
		dir=lerp(dir,Vector2.ZERO,delta*agility)
	elif actor_dis<distance:
		dir = lerp(dir,-actor.to_local(nav_agent.get_next_path_position()).normalized(), delta*agility)
		print_debug(dir)
	else:
		dir = lerp(dir,actor.to_local(nav_agent.get_next_path_position()).normalized(), delta*agility)
		print_debug(dir)
	if chasing_state!=null:
		chasing_state.chase_speed=cur_speed



func face_player() -> void:
	if not active:
		return	
	#else:
	if not vision_handler.player_right:
		animated_sprite_2d.scale.x = 1
		if hit_box !=null:
			hit_box.scale.x = 1
		hurt_box.scale.x=1
		
		if attack_range!=null:
			if attack_range.position.x>0:
				attack_range.position.x *= -1
			
		if bullet_detection != null:
			bullet_detection.scale.x =1
	else:
		animated_sprite_2d.scale.x = -1
		if hit_box !=null:
			hit_box.scale.x = -1
		hurt_box.scale.x=-1
		
		if attack_range!=null:
			if attack_range.position.x<0:
				attack_range.position.x *= -1

		if bullet_detection != null:
			bullet_detection.scale.x =-1
