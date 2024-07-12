extends ColorRect

var stamina : float = 100.0
var current_angle = -1.6
@export var player : CharacterBody3D
var is_gliding : bool = false

var min_angle = -1.6
var max_angle = 4.7

func _draw():
	draw_stamina_meter(Vector2(0,0), 40, 37, current_angle, Color('#71e958'))
	
	draw_stamina_meter(Vector2(0,0), 70, 11, 2, Color('#ff3434'))
	
func draw_stamina_meter(pos, size, width, current, color):
	
	draw_arc(pos, size, max_angle, min_angle, 800, Color(0,0,0,0.5) , width, true)
	
	draw_arc(pos, size, max_angle, current, 800, color , width, true)
	
func _process(delta):
	#if Input.is_action_pressed("forward"):
		#stamina += 1
	#if Input.is_action_pressed("back"):
		#stamina -= 1
	if is_gliding:
		stamina -= 0.05
	else:
		stamina += 0.075
	
	#if is_gliding:
		#stamina -= 1
	#else:
		#stamina += 1
	stamina = clamp(stamina, 0.0, 100.0)
	
	var value = ((min_angle * -1) + max_angle) / 100
	current_angle = max_angle - (stamina * value)
	if stamina < 100:
		visible = true
		queue_redraw()
	if stamina >= 100:
		visible = false
	#queue_redraw()
	
func _physics_process(delta):
	if !player.is_on_floor() and Input.is_action_just_pressed("glide"):
		if is_gliding:
			is_gliding = false
			#print("glide off")
		else:
			if !is_gliding:
				is_gliding = true
				#print("glide on")
	else:
		if player.is_on_floor():
			is_gliding = false
