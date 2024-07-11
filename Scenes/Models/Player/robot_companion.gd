extends CharacterBody3D
 
# Movement speed
const SPEED = 5.0
var player
@export var turn_speed = 4.0

func _ready():
	player = get_tree().get_nodes_in_group("player")[0]

func _physics_process(delta):
	$FaceDirection.look_at(player.global_transform.origin, Vector3.UP)
	rotate_y(deg_to_rad($FaceDirection.rotation.y * turn_speed))
	$NavigationAgent3D.set_target_position(player.global_transform.origin)
	var velocity = ($NavigationAgent3D.get_next_path_position() - transform.origin).normalized() * SPEED * delta
	move_and_collide(velocity)
	
 
