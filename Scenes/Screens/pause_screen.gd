extends ColorRect

@onready var animator : AnimationPlayer = $AnimationPlayer
@onready var play_button : Button = get_node("%ResumeButton")
@onready var quit_button : Button = get_node("%QuitButton")

func _ready():
	play_button.pressed.connect(unpause)
	quit_button.pressed.connect(get_tree().quit)
func unpause():
	animator.play("Unpause")
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func pause():
	animator.play("Pause")
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
