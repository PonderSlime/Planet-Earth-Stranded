extends ColorRect

var coins : int = 0
var current_angle = -1.6
@export var player : CharacterBody3D
var is_gliding : bool = false

var min_angle = -1.6
var max_angle = 4.7

func _draw():
	draw_coin_meter(Vector2(0,0), 40, 37, current_angle, Color('#71e958'))
	
	draw_coin_meter(Vector2(0,0), 70, 11, 2, Color('#ff3434'))
	
func draw_coin_meter(pos, size, width, current, color):
	
	draw_arc(pos, size, max_angle, min_angle, 800, Color(0,0,0,0.5) , width, true)
	
	draw_arc(pos, size, max_angle, current, 800, color , width, true)
	
func _process(delta):
	
	var value = ((min_angle * -1) + max_angle) / 100
	current_angle = max_angle - (coins * value)
	if coins > 0:
		visible = true
		queue_redraw()
	if coins <= 0:
		visible = false
	#queue_redraw()
func _on_player_coin_collected():
	coins += 1
