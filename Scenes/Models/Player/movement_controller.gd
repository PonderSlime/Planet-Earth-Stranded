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
@export var glide_speed = 1
var is_gliding : bool = false
var glide_gravity : float = 1/100 #glide_speed/50

func _physics_process(delta):
	velocity.x = speed * direction.normalized().x
	velocity.z = speed * direction.normalized().z
	
	#glide_gravity * 10
	# Falling function
	if not player.is_on_floor():
		if velocity.y >= 0 and !is_gliding:
			velocity.y -= jump_gravity * delta
		elif velocity.y < 0 and is_gliding:
			print("gliding bool initial velocity")
			velocity.y -= glide_gravity * delta
			velocity.x = 8 * direction.normalized().x
			velocity.z = 8 * direction.normalized().z
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
	#print("jump_state.apex_duration=",jump_state.apex_duration)
	#print("velocity.y=",velocity.y)
	jump_gravity = velocity.y / jump_state.apex_duration
	#print("jump_state.apex_duration2=",jump_state.apex_duration)
	#print("velocity.y2=",velocity.y)
	
	#velocity.y = 2 * jump_state.jump_height 
	#jump_gravity = velocity.y 
	
func _glide(glide_state : GlideState):
	print("gliding math")
	velocity.y = 2 * 1.5 / 0.2 #movement_state
	glide_gravity = velocity.y / 0.2
