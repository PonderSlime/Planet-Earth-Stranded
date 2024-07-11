extends Node2D

var stamina : float = 100

func _draw():
	pass

func _process(delta):
	if Input.is_action_pressed("forward"):
		stamina += 1
	if Input.is_action_pressed("back"):
		stamina -= 1
	print(stamina)
