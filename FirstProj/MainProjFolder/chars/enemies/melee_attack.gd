class_name MeleeAttackState extends LimboState

@export var actor : Node2D
@export var movement_handler : MovementHandler
@export var animation_player : AnimationPlayer
@export var anim_name : StringName
@export var hit_box : HitBox


func _enter() -> void:
	hit_box.collision_shape.set_deferred("disabled", false)
	movement_handler.face_player_active=false
	movement_handler.active=false
	#actor.velocity.x=0
	actor.current_speed=0
	animation_player.play(anim_name)
	
	
func _exit() -> void:
	movement_handler.face_player_active=true
