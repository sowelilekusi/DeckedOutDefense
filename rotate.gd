extends Node3D

@export var speed: float = 1.0


func _process(delta: float) -> void:
	rotation_degrees.y += speed * delta
