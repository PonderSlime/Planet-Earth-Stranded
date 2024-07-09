extends Node

signal is_hurt
@export var player : CharacterBody3D
@export var mesh_root : Node3D
@export var camera_cast : RayCast3D
@export var grapple_mesh : MeshInstance3D
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

var grapple_raycast_hit
var grapple_hook_position : Vector3
var is_grappling : bool = false

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
		elif is_gliding:
			glide_mode.emit(glide_states["glide"])
			velocity.y = 0
			velocity.y -= (glide_gravity) * delta
			velocity.x = 8 * direction.normalized().x
			velocity.z = 8 * direction.normalized().z
			gravity_vec = Vector3.ZERO
			speed = 0
		else:
			velocity.y -= fall_gravity * delta
			gravity_vec += Vector3.DOWN * fall_gravity * delta
	elif player.is_on_floor():
		if gravity_vec.length() >= 20:
			health -= gravity_vec.length()
			hurt(1 * gravity_vec.length())
			print(health)
			is_hurt.emit()
			gravity_vec = Vector3.ZERO
			velocity.y = 0
		else:
			if gravity_vec.length() < 20 and player.is_on_floor():
				gravity_vec = Vector3.ZERO
	
	
	grapple_raycast_hit = camera_cast.get_collider()
	if grapple_raycast_hit:
		$ColorRect.color = "DDDDDD99"
	else:
		$ColorRect.color = "22222255"
	if Input.is_action_just_pressed("grapple"):
		if grapple_raycast_hit:
			grapple_hook_position = camera_cast.get_collision_point()
			is_grappling = true
			grapple_mesh.visible = true
			rope_generator.SetPlayerPosition(position)
			rope_generator.SetGrappleHookPosition(grapple_hook_position)
			rope_generator.StartDrawing()
			rope_generator.visible = true
		else:
			is_grappling = false
	elif Input.is_action_just_released("grapple"):
		grapple_mesh.visible = false
		rope_generator.StopDrawing()
		rope_generator.visible = false
	
	if is_grappling && Input.is_action_pressed("grapple"):
		rope_generator.SetPlayerPosition(position)
		$ColorRect.color = "FF555599"
		grapple_pivot.look_at(grapple_hook_position)
		
		var grapple_direction = (grapple_hook_position - position).normalized()
		var grapple_target_speed = grapple_direction * GRAPPLE_FORCE_MAX
		
		var grapple_dif = (grapple_target_speed - velocity)
	 
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
