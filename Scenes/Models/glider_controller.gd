extends Node

@export var mesh_root : Node3D
@export var glider_spawn : Node3D
@export var glider : CharacterBody3D
@export var player : CharacterBody3D
@export var rotation_speed : float = 8
@export var fall_gravity = 2
var direction : Vector3
var velocity : Vector3
var acceleration : float
var speed : float
var cam_rotation : float = 0
var is_gliding : bool = false 

var jump_gravity : float = fall_gravity

func _physics_process(delta):
	if is_gliding:
		velocity.x = speed * direction.normalized().x
		velocity.z = speed * direction.normalized().z
		glider.velocity = player.velocity.lerp(velocity, acceleration * delta)
		glider.move_and_slide()
	else:
		glider.global_position = glider_spawn.global_position
	
	var target_rotation = atan2(direction.x, direction.z) - glider.rotation.y
	glider.rotation.y = lerp_angle(mesh_root.rotation.y, target_rotation, rotation_speed * delta)

func _on_set_movement_state(_movement_state : MovementState):
	speed = _movement_state.movement_speed
	acceleration = _movement_state.acceleration
	
func _on_set_movement_direction(_movement_direction : Vector3):
	direction = _movement_direction.rotated(Vector3.UP, cam_rotation)
	
func _on_set_cam_rotation(_cam_rotation: float):
	cam_rotation = _cam_rotation
	
func _jump(jump_state : JumpState):
	velocity.y = 2 * jump_state.jump_height / jump_state.apex_duration
	jump_gravity = velocity.y / jump_state.apex_duration

#func _glide(glide_state : GlideState):
	#print("gliding")  
