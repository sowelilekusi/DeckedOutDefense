extends Camera3D

@export var clone_camera : Node3D

func _process(_delta: float) -> void:
	global_position = clone_camera.global_position
	global_rotation = clone_camera.global_rotation
