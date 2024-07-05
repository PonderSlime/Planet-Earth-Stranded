extends Node

@export var player : CharacterBody3D
@export var mesh_root : Node3D
@export var rotation_speed : float = 8
@export var fall_gravity = 10
var direction : Vector3
var velocity : Vector3
var acceleration : float
var speed : float
var cam_rotation : float = 0

var jump_gravity : float = fall_gravity
var glide_gravity : float = fall_gravity
var is_gliding : bool = false

func _physics_process(delta):
	velocity.x = speed * direction.normalized().x
	velocity.z = speed * direction.normalized().z
	
	glide_gravity = 1 / 3
	
	
	if not player.is_on_floor():
		if velocity.y >= 0 and !is_gliding:
			velocity.y -= jump_gravity * delta
		if is_gliding:
			velocity.y -= glide_gravity * delta
		else:
			velocity.y -= fall_gravity * delta
			
	if Input.is_action_just_pressed("glide") and !is_gliding:
		is_gliding = true
		print("gliding")
	elif Input.is_action_just_pressed("glide") and is_gliding:
		is_gliding = false
		velocity.y = 0
		print("stopped gliding")
	elif player.is_on_floor(): 
		is_gliding = false

	
	player.velocity = player.velocity.lerp(velocity, acceleration * delta)
	player.move_and_slide()
	
	var target_rotation = atan2(direction.x, direction.z) - player.rotation.y
	mesh_root.rotation.y = lerp_angle(mesh_root.rotation.y, target_rotation, rotation_speed * delta)

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
	
func _glide(glide_state : GlideState):
	if is_gliding:
		velocity.y = 2 * glide_state.glide_height / 10
		#glide_gravity = velocity.y / glide_state.glide_duration
		

	
