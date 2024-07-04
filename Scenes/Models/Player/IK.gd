extends Node3D


@export var min_max_interpolation : Vector2 = Vector2(0, 0.9)
@export var foot_height_offset : float = 0.05

@onready var target_left = $Target_Left
@onready var target_right = $Target_Right
@onready var raycast_left = $RayCast_Left
@onready var raycast_right = $RayCast_Right
@onready var ik_left = $Armature/Skeleton3D/SkeletonIK3D_Left
@onready var ik_right = $Armature/Skeleton3D/SkeletonIK3D_Right
@onready var no_raycast_pos_l = $no_raycast_target_l
@onready var no_raycast_pos_r = $no_raycast_target_r

func _ready():
	ik_left.start()
	ik_right.start()
	
func update_ik_target_pos(target, raycast, no_raycast_pos, foot_height_offset):
	if raycast.is_colliding():
		var hit_point = raycast.get_collision_point().y + foot_height_offset
		target.global_transform.origin.y = hit_point
	else:
		target.global_transform.origin.y = no_raycast_pos.global_transform.origin.y
		
func _physics_process(delta):
	update_ik_target_pos(target_left, raycast_left, no_raycast_pos_l, foot_height_offset)
	update_ik_target_pos(target_right, raycast_right, no_raycast_pos_r, foot_height_offset)
