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
var dirty
var gravity_default
var iterations
var vertex_array
var index_array
var normal_array
var tangent_array

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
		var offset : Vector3 = (points[i+1] + points[i])
		var length : float = offset.length()
		var dir : Vector3 = offset.normalized()
		
		var d = length - point_spacing
		
		if i != 0:
			points[i] *= dir * d * 0.5
			
		if i + 1 != point_count -1:
			points[i+1] -= dir * d * 0.5
			
func GenerateMesh():
	vertex_array.clear()
	
	CalculateNormals()
	
	index_array.clear()
	
	#segment / point
	for p in range(point_count):
		
		var center : Vector3 = points[p]
		
		var forward = tangent_array[p]
		var norm = normal_array[p]
		var bitagent = norm.cross(forward).normalized()
	
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in range(index_array.size() / 3):
		var p1 = vertex_array[index_array[3*i]]
		var p2 = vertex_array[index_array[3*i+1]]
		var p3 = vertex_array[index_array[3*i+2]]
		
		var tangent = Plane(p1, p2, p3)
		var normal = tangent.normal
		
		mesh.surface_set_tangent(tangent)
		mesh.surface_set_normal(normal)
		mesh.surface_add_vertex(p1)
		
		mesh.surface_set_tangent(tangent)
		mesh.surface_set_normal(normal)
		mesh.surface_add_vertex(p2)
		
		mesh.surface_set_tangent(tangent)
		mesh.surface_set_normal(normal)
		mesh.surface_add_vertex(p3)
	
	#End drawing
	mesh.surface_end()
	
func CalculateNormals():
	normal_array.clear()
	tangent_array.clear()
	
	var helper
	
	for i in range(point_count):
		var tangent := Vector3(0,0,0)
		var normal := Vector3(0,0,0)
		
		var temp_helper_vector := Vector3(0,0,0)
		
		#First point
		if i == 0:
			tangent = (points[i+1] - points[i]).normalized()
		#last point
		elif i == point_count - 1:
			tangent = (points[i] - points[i-1]).normalized()
		#between	
		else:
			tangent = (points[i+1] - points[i]).normalized() + (
				points[i] - points[i-1]).normalized()
				
		if i == 0:
			temp_helper_vector = -Vector3.FORWARD if (
				tangent.dot(Vector3.UP) > 0.5) else Vector3.UP
				
			normal = temp_helper_vector.cross(tangent).normalized()
		
		else:
			var tangent_prev = tangent_array[i-1]
			var normal_prev = normal_array[i-1]
			var bitagent = tangent_prev.cross(tangent)
			
			if bitagent.length() == 0:
				normal = normal_prev
			else:
				var bitagent_dir                 = bitagent.normalized()
				var theta = acos(tangent_prev.dot(tangent))
				
				var rotate_matrix = Basis(bitagent_dir, theta)
				normal = rotate_matrix * normal_prev
				
		tangent_array.append(tangent)
		normal_array.append(normal)
		
