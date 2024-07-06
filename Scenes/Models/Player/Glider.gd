extends Node3D

@export var player : CharacterBody3D

var is_gliding : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func _physics_process(delta):
	if is_gliding:
		self.visible = true
		#print("glider visible")
	elif !is_gliding:
		self.visible = false
		#print("glider disengaged")
	if player.is_on_floor():
		is_gliding = false
	
func _glide(glide_state : GlideState):
	# Button toggle current glider animation on/off
	if !player.is_on_floor() and Input.is_action_just_pressed("glide"):
		if is_gliding:
			is_gliding = false
			#print("glide on")
		else:
			if !is_gliding:
				is_gliding = true
				#print("glide off")

			#print("landed")
