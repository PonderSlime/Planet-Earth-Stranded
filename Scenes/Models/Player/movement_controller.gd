extends Node

signal is_hurt
@export var player : CharacterBody3D
@export var mesh_root : Node3D
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

var jump_gravity : float = fall_gravity
@export var glide_speed = 100
var is_gliding : bool = false
var glide_gravity = glide_speed #glide_speed/50

signal glide_mode(glide_state : GlideState)
@export var glide_states : Dictionary

var gravity_vec : Vector3
var health : int = 100

var hurt_tween : Tween

func _ready():
	health = 100
	health_bar.init_health(health)
func _physics_process(delta):
	velocity.x = speed * direction.normalized().x
	velocity.z = speed * direction.normalized().z
	
	#glide_gravity * 10
	# Falling function
	if not player.is_on_floor():
		if velocity.y >= 0 and !is_gliding:
			velocity.y -= jump_gravity * delta
			gravity_vec += Vector3.DOWN * fall_gravity * delta
			#speed = 0
		#elif velocity.y <= 0 and is_gliding:
			##print("gliding bool initial velocity")
			#velocity.y -= glide_gravity * delta
			#velocity.x = 8 * direction.normalized().x
			#velocity.z = 8 * direction.normalized().z
		elif is_gliding:
			glide_mode.emit(glide_states["glide"])
			velocity.y = 0
			velocity.y -= (glide_gravity) * delta
			velocity.x = 8 * direction.normalized().x
			velocity.z = 8 * direction.normalized().z
			gravity_vec = Vector3.ZERO
			speed = 0
				
			#print("glide gravity =", velocity.y)
		else:
			velocity.y -= fall_gravity * delta
			#print("fall gravity =", velocity.y)
			gravity_vec += Vector3.DOWN * fall_gravity * delta
			#speed = 0
	elif player.is_on_floor():
		if gravity_vec.length() >= 20:
			health -= gravity_vec.length()
			print(health)
			hurt(-health + 100)
			is_hurt.emit()
			gravity_vec = Vector3.ZERO
			velocity.y = 0
		elif gravity_vec.length() < 20:
			gravity_vec = Vector3.ZERO
	#print(velocity.y)
			
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

	
	player.velocity = player.velocity.lerp(velocity, acceleration * delta)
	player.move_and_slide()
	
	var target_rotation = atan2(direction.x, direction.z) - player.rotation.y
	mesh_root.rotation.y = lerp_angle(mesh_root.rotation.y, target_rotation, rotation_speed * delta)
	
	if speed > 3:
		speed_overlay.modulate = Color.WHITE
	elif speed <3:
		speed_overlay.modulate = Color.TRANSPARENT

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
