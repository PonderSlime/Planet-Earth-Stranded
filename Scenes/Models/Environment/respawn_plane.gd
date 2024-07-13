extends Node3D
signal respawn

func _on_area_3d_body_entered(body):
	respawn.emit()
