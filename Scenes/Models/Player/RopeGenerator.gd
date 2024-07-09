extends MeshInstance3D

@export var player : CharacterBody3D
@export var grapple_hook : MeshInstance3D
var isDrawing : bool
var points
var points_old
var point_count
var rope_length : float
var point_spacing : float
var firstTime = true

var player_position
var grapple_hook_position


func _process(delta):
	if isDrawing || dirty:
		if firstTime:
			PreparePoints()
			firstTime = false
		UpdatePoints(delta)
		
		GenerateMesh()
		
		dirty = false
		
func SetGrappleHookPosition(val : Vector3):
	grapple_hook_position = val
	firstTime = true
	
func SetPlayerPosition(val : Vector3):
	player_position = val

func StartDrawing():
	isDrawing = true
	
func StopDrawing():
	isDrawing = false
	
func PreparePoints():
	points.clear()
	points_old.clear()
	
	for i in range(point_count):
		var t = i / (point_count - 1.0)
		
		points.append(lerp(player_position, grapple_hook_position, t))
		points_old.append(points[i])
		
	_UpdatePointSpacing()
	
func _UpdatePointSpacing():
	rope_length = (grapple_hook_position - player_position).length()
	point_spacing = rope_length / (point_count - 1.0)
	
func UpdatePoints(delta):
	points[0] = player_position
	points[point_count - 1] = grapple_hook_position
	
	_UpdatePointSpacing()
	
	for i in range(1, point_count, -1):
		var curr : Vector3 = points[i]
		points[i] = points[i] + (points[i] - points_old[i]) + (
			Vector3.DOWN * gravity_default * delta * delta)
		points_old[i] = curr
		
	for i in range(iterations):
		ConstraintConnections()
		
func ConstraintConnections():
	
	for i in range(point_count - 1):
		var centre : Vector3 = (points[i+1] + points[i]) / 2.0
