extends Node

@export var fall_damage_player : AudioStreamPlayer
@export var main_song : AudioStreamPlayer
var CorrectSound = preload("res://Assets/Sound/Music/Song 1.wav")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !main_song.is_playing():
		main_song.stream = CorrectSound
		main_song.play()
	
func _hurt():
	fall_damage_player.play()
