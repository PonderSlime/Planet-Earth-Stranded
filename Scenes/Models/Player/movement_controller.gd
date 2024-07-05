extends Node

@export var player : CharacterBody3D
@export var mesh_root : Node3D
@export var wall_check : RayCast3D
@export var still_on_wall_check : RayCast3D
@export var rotation_speed : float = 8
@export var fall_gravity = 10
var gravity_enabled = true
var direction : Vector3
var velocity : Vector3
var acceleration : float
var speed : float
var cam_rotation : float = 0

var jump_state : JumpState
var jump_gravity : float = fall_gravity
var is_climbing : bool
var gravity_vec : Vector3

func _physics_process(delta):
	velocity.x = speed * direction.normalized().x
	velocity.z = speed * direction.normalized().z
	
	if not player.is_on_floor():
		if gravity_enabled:
			if velocity.y >= 0:
				velocity.y -= jump_gravity * delta
			else:
				velocity.y -= fall_gravity * delta
		else:
			velocity.y = 0
				
	
	if gravity_enabled:
		player.velocity = player.velocity.lerp(velocity, acceleration * delta) + gravity_vec
	else:
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
		

func climbing(climb_state : ClimbState):
	#check if the player is able to climb
	if wall_check.is_colliding():
		if still_on_wall_check.is_colliding():
			if Input.is_action_pressed("climb"):
				if player.is_on_floor():
					is_climbing = false
					print("can't climb")
				else:
					is_climbing = true
					print("climb")
			elif is_climbing and Input.is_action_pressed("climb"):
				is_climbing = false
				gravity_enabled = true		
			else:
				is_climbing = false
				print("colliding with wall")
		else:
			#if player is at the top of a climb, boost them over the top
			velocity.y = 2 * jump_state.jump_height / jump_state.apex_duration
			jump_gravity = velocity.y / jump_state.apex_duration
			await(get_tree().create_timer(0.3, true))
			is_climbing = false 
	elif !wall_check.is_colliding():
		if !still_on_wall_check.is_colliding():
			is_climbing = false
			print("not colliding")
	
	if is_climbing:
		#if the player is climbing disable gravity
		gravity_enabled = false
		speed = climb_state.climb_speed 
		direction = Vector3.ZERO
		 #gravity is set to zero to prevent it building up
		
		var rot = -(atan2(wall_check.get_collision_normal().z, wall_check.get_collision_normal().x) - PI/2)
		var f_input = Input.get_action_strength("forward") - Input.get_action_strength("back")
		var h_input = Input.get_action_strength("right") - Input.get_action_strength("left")
		direction = Vector3(h_input, f_input, 0).rotated(Vector3.UP, rot).normalized()
	else:
		#velocity.y = 0
		gravity_enabled = true
		
#func _process(delta):
	#if direction != Vector3.ZERO and !is_climbing:
		#mesh_root.rotation.y = lerp_angle(player.rotation.y, atan2(-direction.x, -direction.z), mesh_root.rotation.y * delta)
	#if direction != Vector3.ZERO and is_climbing:
		#mesh_root.rotation.y = -(atan2(wall_check.get_collision_normal().z, wall_check.get_collision_normal().x) - PI/2)	
