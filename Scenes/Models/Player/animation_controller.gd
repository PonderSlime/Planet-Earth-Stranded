extends Node


@export var animation_tree : AnimationTree
@export var player : CharacterBody3D

var tween : Tween
var on_floor_blend : float = 1
var on_floor_blend_target : float = 1
var is_gliding : bool = false

func _physics_process(delta):
	on_floor_blend_target = 1 if player.is_on_floor() else 0
	on_floor_blend = lerp(on_floor_blend, on_floor_blend_target, 10 * delta)
	animation_tree["parameters/on_floor_blend/blend_amount"] = on_floor_blend
	if is_gliding:
		animation_tree["parameters/is_gliding/blend_amount"] = 1
	elif !is_gliding:
		animation_tree["parameters/is_gliding/blend_amount"] = 0
	
func _process(delta):
	if Input.is_action_just_pressed("glide"):
		is_gliding = !is_gliding

func _on_set_movement_state(_movement_state : MovementState):
	if tween:
		tween.kill()
		
	tween = create_tween()
	tween.tween_property(animation_tree, "parameters/movement_blend/blend_position", _movement_state.id, 0.25)
	tween.parallel().tween_property(animation_tree, "parameters/movement_anim_speed/scale", _movement_state.animation_speed, 0.7)

func _jump(jump_state : JumpState):
	animation_tree["parameters/" + jump_state.animation_name + "/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func _glide(glide_state : GlideState):
	pass

	
