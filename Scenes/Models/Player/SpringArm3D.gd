extends SpringArm3D

@export var player:CharacterBody3D

func _ready() -> void:
	if player:
		add_excluded_object(player.get_rid())
