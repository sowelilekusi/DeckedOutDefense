class_name NetworkPuppeteer extends Node

@export var player: CharacterBody3D
@export var player_movement: PlayerMovement
@export var skeleton: Skeleton3D


func _process(delta: float) -> void:
	if is_multiplayer_authority():
		set_position.rpc(player.global_position)
		set_rotation.rpc(player_movement.head_angle, player.rotation.y)


@rpc("unreliable", "call_remote")
func set_position(position: Vector3) -> void:
	player.global_position = position


@rpc("unreliable", "call_remote")
func set_rotation(x: float, y: float) -> void:
	player_movement.head_angle = x
	player.rotation.y = y
	var bone: int = skeleton.find_bone("Head")
	var pos: Quaternion = skeleton.get_bone_pose_rotation(bone)
	skeleton.set_bone_pose_rotation(bone, Quaternion.from_euler(Vector3(x, 0, 0)))
