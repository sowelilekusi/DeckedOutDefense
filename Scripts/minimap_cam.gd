extends Camera3D
class_name MinimapCamera3D

@export var anchor : Node3D
@export var face_north : bool

func _process(_delta: float) -> void:
	global_position = anchor.global_position + (Vector3.UP * 100)
	if face_north:
		rotation.y = anchor.rotation.y
