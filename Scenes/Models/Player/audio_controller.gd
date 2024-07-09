extends Node

@export var fall_damage_player : AudioStreamPlayer
@export var main_song : AudioStreamPlayer

@export var sound_effects : AudioStreamPlayer
var CorrectSound = preload("res://Assets/Sound/Music/Song 1.wav")
var Wind = preload("res://Assets/Sound/Effects/wind.mp3")
var is_gliding : bool = false
@export var player : CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !player.is_on_floor() and Input.is_action_just_pressed("glide"):
		if is_gliding:
			is_gliding = false
			#print("glide off")
		else:
			if !is_gliding:
				is_gliding = true
				#print("glide on")
	else:
		if player.is_on_floor():
			is_gliding = false
	
	#if !main_song.is_playing():
		#main_song.stream = CorrectSound
		#main_song.play()
		
	if is_gliding:
		if !sound_effects.is_playing():
			sound_effects.stream = Wind
			sound_effects.volume_db = 2
			sound_effects.play()
	elif player.is_on_floor():
		sound_effects.stop()

func _hurt():
	fall_damage_player.play()

func _glide():
	pass
