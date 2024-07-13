extends Node3D
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group("player")[0]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func coin_picked_up():
	queue_free()
func _on_area_3d_body_entered(body):
	player.coin()
	coin_picked_up()
