extends CanvasLayer

func _on_button_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_button_quit_pressed():
	get_tree().quit()
