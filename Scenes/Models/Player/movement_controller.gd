extends Node
#class_name Skeleton3D

signal is_hurt
@export var player : CharacterBody3D
@export var mesh_root : Node3D
@export var camera_cast : RayCast3D
@export var hurt_overlay : TextureRect
@export var speed_overlay : ColorRect
@export var health_bar : ProgressBar 
@export var rotation_speed : float = 8
@export var fall_gravity = 10
var direction : Vector3
var velocity : Vector3
var acceleration : float
var speed : float
var cam_rotation : float = 0
var position

var jump_gravity : float = fall_gravity
@export var glide_speed = 100
var is_gliding : bool = false
var glide_gravity = glide_speed #glide_speed/50

# Should have a signal coming in that specifiecs the player skeleton
@export var skeleton : Skeleton3D

#for calculating velocity from position frames of the foot
var prev_position: Vector3
var prev_idx: int # For point tracking handoff
var prev_velocity: Vector3
#The original game designer for some reason scaled the robot or the animation, so it messes up my code.
# This appears to be the animation scaling value they used
var arbitrary_scaling_value = 0.2

# The current movement state
var state_id
var jump
var movement_speed

signal glide_mode(glide_state : GlideState)
@export var glide_states : Dictionary

var gravity_vec : Vector3
var health : int = 100

var hurt_tween : Tween
@onready var ray_01 = $"../MeshRoot/Ray01"
@onready var ray_02 = $"../MeshRoot/Ray02"
var onledge : bool = false

func _ready():
	health = 100
	health_bar.init_health(health)

func _physics_process(delta):
	# 1 is walking, so apply the velocity based on animation
	if state_id == 1  and jump != "jump":
		# z velocity is the forward/backward movement
		speed = -_calculate_player_movement(delta).z
	#Otherwise apply the speed from whatever other movement type
	else:
		speed = movement_speed

	velocity.x = speed * direction.normalized().x
	velocity.z = speed * direction.normalized().z
	
	#glide_gravity * 10
	# Falling function
	if not player.is_on_floor():
		if velocity.y >= 0 and !is_gliding:
			velocity.y -= jump_gravity * delta
			gravity_vec += Vector3.DOWN * fall_gravity * delta
		elif is_gliding:
			glide_mode.emit(glide_states["glide"])
			velocity.y = 0
			velocity.y -= (glide_gravity) * delta
			velocity.x = 8 * direction.normalized().x
			velocity.z = 8 * direction.normalized().z
			gravity_vec = Vector3.ZERO
			speed = movement_speed
		else:
			velocity.y -= fall_gravity * delta
			gravity_vec += Vector3.DOWN * fall_gravity * delta
	elif player.is_on_floor():
		if gravity_vec.length() >= 20:
			health -= (5 * gravity_vec.length())
			hurt(5 * gravity_vec.length())
			print(health)
			is_hurt.emit()
			gravity_vec = Vector3.ZERO
			velocity.y = 0
		else:
			if gravity_vec.length() < 20 and player.is_on_floor():
				gravity_vec = Vector3.ZERO
	 
	if Input.is_action_just_pressed("glide") and !is_gliding and !player.is_on_floor():
		is_gliding = true
		#print("gliding")
	elif Input.is_action_just_pressed("glide") and is_gliding and !player.is_on_floor():
		is_gliding = false
		velocity.y = 0
		#print("stopped gliding")
	elif player.is_on_floor(): 
		is_gliding = false
		#print("landed")
	
	# Not sure if the acceleration will affect the walk animation
	#player.velocity = player.velocity.lerp(velocity, acceleration * delta)
	player.velocity = velocity
	player.move_and_slide()
	
	var target_rotation = atan2(direction.x, direction.z) - player.rotation.y
	mesh_root.rotation.y = lerp_angle(mesh_root.rotation.y, target_rotation, rotation_speed * delta)
	
	if state_id == 2:
		speed_overlay.modulate = Color.WHITE
	elif state_id != 2:
		speed_overlay.modulate = Color.TRANSPARENT
	if player.is_on_floor():
		jump = "no_jump"
	elif !player.is_on_floor():
		jump = "jump"

func _on_set_movement_state(_movement_state : MovementState):
	movement_speed = _movement_state.movement_speed
	#speed = movement_speed
	acceleration = _movement_state.acceleration
	state_id = _movement_state.id
	
func _on_set_movement_direction(_movement_direction : Vector3):
	direction = _movement_direction.rotated(Vector3.UP, cam_rotation)
func _on_set_cam_rotation(_cam_rotation: float):
	cam_rotation = _cam_rotation
	
func _jump(jump_state : JumpState):
	jump = jump_state.animation_name
	velocity.y = 2 * jump_state.jump_height / jump_state.apex_duration
	#print("jump_state.apex_duration=",jump_state.apex_duration)
	#print("velocity.y=",velocity.y)
	jump_gravity = velocity.y / jump_state.apex_duration
	#print("jump_state.apex_duration2=",jump_state.apex_duration)
	#print("velocity.y2=",velocity.y)

	
	#velocity.y = 2 * jump_state.jump_height 
	#jump_gravity = velocity.y 
	
func _glide(glide_state : GlideState):
	#print("gliding math")	
	#velocity.y = 2 * glide_state.glide_height / glide_state.glide_duration #movement_state
	#glide_gravity = velocity.y / glide_state.glide_duration
	pass
func hurt(damage : float):
	health_bar.health = health
	#health_bar.value -= damage
	hurt_overlay.modulate = Color.WHITE
	if hurt_tween:
		hurt_tween.kill()
	hurt_tween = create_tween()
	hurt_tween.tween_property(hurt_overlay, "modulate", Color.TRANSPARENT, 0.75)

# Calculates player movement based on bone translation for realistic walking
func _calculate_player_movement(dt: float):
	var velocity : Vector3
	
	# Relavant bone idx numbers:
	# Right foot Heel: 37, Toe: 36
	# Left Foot Heel: 48, Toe: 47
	
	# The vertical dimension is Y, roughly -4.989 when flat on ground
	
	# All the points that are being used to track motion
	var point_array: Array[Vector3] = [
		skeleton.get_bone_global_pose(37).origin, # R heel
		skeleton.get_bone_global_pose(36).origin, # R Toe
		skeleton.get_bone_global_pose(48).origin, # L Heel
		skeleton.get_bone_global_pose(47).origin # L Toe
	]
	# Find the bone point that currently is closest to the floor
	var value = _find_lowest_value(point_array, "y")
	var position = value.lowest_vect
	
	# Handoff of points. If the point changed set the velocity to the same it was, reset prev_position, and skip normal velocity code
	if prev_idx != value.idx:
		velocity = prev_velocity
		#print("switched points")
	# If the lowest position is out of bounds of the floor(calculated on foot distance from player center), basically leaping,
	# and the controller speed says its still walking or running, set the velocity to last value
	elif position.y < -5.2 or position.y > -4.8:
		velocity.z = -speed
		#print("Off the fLoor, speed = ", speed*5)
	else:
		# Calculate velocity from the change in position and time
		velocity = (position - prev_position) / dt
		#if velocity.z == 0:
		#	velocity = prev_velocity
		#print("velocity: ", velocity.z)
	# removes some of the jitter in movement, it can't go backwards now
	if velocity.z > 0:
		velocity.z = 0
		
	prev_position = position
	prev_velocity = velocity # redundant when switching tracker points, but for most of the code it makes sense for it to be here
	prev_idx = value.idx
	
	return velocity * arbitrary_scaling_value
	
# Takes an array of vectors, compares the specified dimension values to find the lowest, and returns the vector with its index	
func _find_lowest_value(array: Array[Vector3], dimension: String):
	var current_lowest
	var idx = 0
	var lowest_idx = 0
	for i in array:
		if current_lowest == null:
			current_lowest = i
		if i[dimension] < current_lowest[dimension] :
			current_lowest = i
			lowest_idx = idx
		idx += 1
	
	return {"lowest_vect": current_lowest, "idx": lowest_idx}
	
