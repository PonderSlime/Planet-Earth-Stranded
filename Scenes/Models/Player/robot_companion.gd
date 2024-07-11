extends CharacterBody3D

@export var movement_speed : float = 5
@onready var navigation_agent : NavigationAgent3D = get_node("NavigationAgent3D")
@export var target_character : CharacterBody3D
@export var turn_speed = 4.0

func _ready():
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	
var is_moving = false
var RADIUS = 5
@export var behavior = 0

func set_movement_target(movement_target : Vector3):
	if behavior == 0:
		navigation_agent.set_target_position(movement_target)
		
	if behavior == 1 and is_moving:
		var new_position = get_opposite_point(global_position.x, global_position.z, global_position.y, RADIUS, movement_target.x, movement_target.z)
		navigation_agent.set_target_position(new_position)
		
func get_opposite_point(cx, cz, cy, radius, x, z):
	var v = Vector2(x - cx, z - cz)
	var nv = v.normalized()
	var op = Vector2(cx - radius * nv.z, cz - radius * nv.y)
	
	return Vector3(op.x, cy, op.y)

func _physics_process(delta):
	if behavior == 0:
		$FaceDirection.look_at(target_character.global_transform.origin, Vector3.UP)
		rotate_y(deg_to_rad($FaceDirection.rotation.y * turn_speed))
		if !navigation_agent.is_target_reachable() or navigation_agent.distance_to_target() >= 50:
			if target_character.is_on_floor():
				global_position.x = target_character.global_position.x
				global_position.z = target_character.global_position.z - 2
				global_position.y = target_character.global_position.y
	set_movement_target(target_character.global_position)
	
	if navigation_agent.is_navigation_finished():
		return
		
	var next_path_position : Vector3 = navigation_agent.get_next_path_position()
	var current_agent_position : Vector3 = global_position
	var new_velocity : Vector3 = (next_path_position - current_agent_position).normalized() * movement_speed
	
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)
		
func _on_velocity_computed(safe_velocity : Vector3):
	velocity = safe_velocity
	move_and_slide()
