class_name Trail3D extends MeshInstance3D

var _points = [] # Stores all 3D positions that will make up the trail
var _widths = [] # Stores all the calculation widths using the positions of the points
var _lifePoints = [] # Stores all the trail points lifespans

@export var _trailEnabled : bool = true ## Is trail allowed to be shown

@export var _fromWidth : float = 0.5 ## Starting width of the trail
@export var _toWidth : float = 0.0 ## End width of the trail
@export_range(0.5, 1.5) var _scaleAcceleration : float = 1 ## Speed of the scaling

@export var _motionDelta : float = 0.1 ## Sets the smoothness of the trail, how long it will take for a new trail piece to be made
@export var _lifespan : float = 1.0 ## Sets the duration until this part of the trail is no longer used, and is thus removed

@export var _startColor : Color = Color(1.0, 1.0, 1.0, 1.0) ## Starting color of the trail
@export var _endColor : Color = Color(1.0, 1.0, 1.0, 0.0) ## End color of the trail

var _old_pos : Vector3 # Get the previous position

func _ready():
	_old_pos = get_global_transform().origin
	mesh = ImmediateMesh.new()
	
func AppendPoint():
	_points.append(get_global_transform().origin)
	_widths.append([
		get_global_transform().basis.x * _fromWidth,
		get_global_transform().basis.x *_fromWidth - get_global_transform().basis.x * _toWidth])
	_lifePoints.append(0.0)
	
func RemovePoint(i):
	_points.remove_at(i)
	_widths.remove_at(i)
	_lifePoints.remove_at(i)
	
func _process(delta):
	# If the distance between the previous position and the current position is more than the spawn threshold and
	# trails are allowed to be made
	if (_old_pos - get_global_transform().origin).length() > _motionDelta and _trailEnabled:
		AppendPoint() # Create a new point
		_old_pos = get_global_transform().origin # Update the oldPosition to the current position
		
	# Update the lifespan of every point
	var p = 0
	var max_points = _points.size()
	while p < max_points:
		_lifePoints[p] += delta
		if _lifePoints[p] > _lifespan: # If the lifespan of a point has ended, remove it from the list
			RemovePoint(p)
			p -= 1
			if (p < 0): p = 0
		
		max_points = _points.size()
		p += 1
		
	mesh.clear_surfaces()
	
	# If there are no more than 2 points, don't render it and return
	if _points.size() < 2:
		return
		
	#Render a new mesh based on the position of each point and their current width
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	for i in range(_points.size()):
		var t = float(i) / (_points.size() - 1.0)
		var currColor = _startColor.lerp(_endColor, 1 - t)
		mesh.surface_set_color(currColor)
		
		var currWidth = _widths[i][0] - pow(1 - t, _scaleAcceleration) * _widths[i][1]
		
		var t0 = i / _points.size()
		var t1 = t
		
		mesh.surface_set_uv(Vector2(t0, 0))
		mesh.surface_add_vertex(to_local(_points[i] + currWidth))
		mesh.surface_set_uv(Vector2(t1, 1))
		mesh.surface_add_vertex(to_local(_points[i] - currWidth))
	mesh.surface_end()
