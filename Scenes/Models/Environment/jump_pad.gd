extends Node3D
#signal jump_pad
@export var player : CharacterBody3D
	
func _area_3d_area_entered(area):
	#player.velocity.y += 100
	player.jump_pad = true
	#player.jump_pad = false
	await get_tree().create_timer(0.5).timeout
	player.jump_pad = false
