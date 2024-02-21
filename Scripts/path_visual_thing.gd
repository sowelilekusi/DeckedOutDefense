class_name PathVisualThing extends PathFollow3D

@export var speed: float = 0.5
@export var world_model: Node3D
@export var minimap_model: Node3D


func _process(delta: float) -> void:
	progress += speed * delta


func set_world_visible(value: bool) -> void:
	world_model.set_visible(value)


func set_minimap_visible(value: bool) -> void:
	minimap_model.set_visible(value)
