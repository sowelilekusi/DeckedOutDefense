class_name MinimapCamera3D
extends Camera3D

@export var anchor: Node3D
#@export var face_north: bool

func _process(_delta: float) -> void:
	global_position = anchor.global_position + (Vector3.UP * 100)
	if Data.preferences.fixed_minimap:
		rotation.y = 0
	else:
		rotation.y = anchor.rotation.y
