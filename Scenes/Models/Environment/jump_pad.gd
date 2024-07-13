extends Node3D
#signal jump_pad
@export var player : CharacterBody3D
var colliding : bool = false
	
func _area_3d_area_entered(area):
	#player.velocity.y += 100
	player.jump_pad = true
	colliding = true
	#player.jump_pad = false
	await get_tree().create_timer(0.5).timeout
	player.jump_pad = false
	#colliding = false
	
func _physics_process(delta):
	if colliding == true:
		print("colliding")
		player.jump_pad = true
		if player.velocity.y > 1.5:
			await get_tree().create_timer(0.5).timeout
			player.jump_pad = false
			colliding = false
