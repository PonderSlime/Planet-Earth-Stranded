extends Node

@onready var yaw_node = $CamYaw
@onready var pitch_node = $CamYaw/CamPitch
@onready var camera = $CamYaw/CamPitch/Camera3D

var yaw :float = 0
var pitch : float = 0

var yaw_sensitivity :float = 0.07
var pitch_sensitivity :float = 0.07

var yaw_acceleration : float = 15
var pitch_acceleration : float = 15


func _input(event):
	if event is InputEventMouseMotion:
		yaw += -event.relative.x * yaw_sensitivity
		pitch += event.relative.y * pitch_sensitivity
		
		
func _physics_process(delta):
	yaw_node.rotation_degrees.y = lerp(yaw_node.rotation_degress.y, yaw, yaw_acceleration * delta)
	pitch_node.rotation_degrees.x = lerp(pitch_node.rotation_degress.x, pitch, pitch_acceleration * delta)
