extends Node3D
signal jump_pad
var player

func _ready():
	player = get_tree().get_nodes_in_group("player")
	
func _area_3d_area_entered(area):
	player.jump_pad.emit()
	print("colliding!")
	player.jump_pad.emit()
