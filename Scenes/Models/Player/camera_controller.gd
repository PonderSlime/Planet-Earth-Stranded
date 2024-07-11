extends Node

signal set_cam_rotation(_cam_rotation : float)

@onready var yaw_node = $CamYaw
@onready var pitch_node = $CamYaw/CamPitch
@onready var spring_arm = $CamYaw/CamPitch/SpringArm3D
@onready var camera = $CamYaw/CamPitch/SpringArm3D/Camera3D
@export var player : CharacterBody3D

var yaw :float = 0
var pitch : float = 0

var yaw_sensitivity :float = 0.1
var pitch_sensitivity :float = 0.1

var yaw_acceleration : float = 30
var pitch_acceleration : float = 30

var pitch_max : float = 75
var pitch_min : float = -55

var tween : Tween
var is_gliding : bool = false

var camera_fov : float

var sensitivity = 0.005
var is_dead = false
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		yaw += -event.relative.x * yaw_sensitivity
		pitch += event.relative.y * pitch_sensitivity
		
	
	
	#var walk = Input.get_axis("move_left", "move_right")
func _physics_process(delta):
	yaw += (Input.get_axis("look_left", "look_right") * (yaw_sensitivity / 2)) * 40
	pitch += (Input.get_axis("look_up", "look_down") * (pitch_sensitivity / 2)) * 40
	pitch = clamp(pitch, pitch_min, pitch_max)
	
	yaw_node.rotation_degrees.y = lerp(yaw_node.rotation_degrees.y, yaw, yaw_acceleration * delta)
	pitch_node.rotation_degrees.x = lerp(pitch_node.rotation_degrees.x, pitch, pitch_acceleration * delta)
	
	set_cam_rotation.emit(yaw_node.rotation.y)
	if !player.is_on_floor() and Input.is_action_just_pressed("glide"):
		if is_gliding:
			is_gliding = false
			print("glide off")
		else:
			if !is_gliding:
				is_gliding = true
				print("glide on")
	else:
		if player.is_on_floor():
			is_gliding = false
			
		if tween:
			tween.kill()
	
		tween = create_tween()
		if !is_gliding:
			tween.tween_property(camera, "fov", camera_fov, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		else:
			tween.tween_property(camera, "fov", 85, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	

func _on_set_movement_state(_movement_state : MovementState):
	camera_fov = _movement_state.camera_fov
