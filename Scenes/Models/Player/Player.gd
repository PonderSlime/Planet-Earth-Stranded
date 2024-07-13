extends CharacterBody3D
signal pressed_jump(jump_state : JumpState)
signal pressed_glide(glide_state : GlideState)
signal set_movement_state(_movement_state: MovementState,)
signal set_movement_direction(_movement_direction: Vector3)
signal jumping_pad
@export var movement_states: Dictionary
@export var jump_states: Dictionary
@export var glide_states: Dictionary
var movement_direction : Vector3
var jump_pad : bool = false
func _input(event):
	if event.is_action("movement"):
		movement_direction.x = Input.get_action_strength("left") - Input.get_action_strength("right")
		movement_direction.z = Input.get_action_strength("forward") - Input.get_action_strength("back")
		
		if is_movement_ongoing():
			if Input.is_action_pressed("run"):
				set_movement_state.emit(movement_states["run"])
			else:
				set_movement_state.emit(movement_states["walk"])
				
		else:
			set_movement_state.emit(movement_states["stand"])

func _ready():
	set_movement_state.emit(movement_states["stand"])


func _physics_process(delta):
	if is_movement_ongoing():
		set_movement_direction.emit(movement_direction)

	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			var jump_name = "jump"
			pressed_jump.emit(jump_states[jump_name])
	if not is_on_floor():	
		if Input.is_action_just_pressed("glide"):
			var glide_name = "glide"
			pressed_glide.emit(glide_states[glide_name])
			print("gliding")
	
	if Input.is_action_pressed("pause"):
		$PauseMenu.pause()
	if jump_pad == true:
		jumping_pad.emit()
		print("jumping_pad")
		
func is_movement_ongoing() -> bool:
	return abs(movement_direction.x) > 0 or abs(movement_direction.z) > 0


func _on_set_movement_direction(_movement_direction):
	pass # Replace with function body.


func _on_set_movement_state(_movement_state):
	pass # Replace with function body.
