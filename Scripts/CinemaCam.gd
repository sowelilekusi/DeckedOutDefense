extends Node3D
class_name CinematicCamManager

@export var path_follows : Array[PathFollow3D]
@export var cameras : Array[Camera3D]
@export var pan_speed := 1.0
var current_cam := 0
var does_its_thing := true


func _ready() -> void:
	for path_follow in path_follows:
		path_follow.progress_ratio = 0.0
	if does_its_thing:
		cameras[0].make_current()


func _process(delta: float) -> void:
	if does_its_thing:
		path_follows[current_cam].progress_ratio += pan_speed * delta
		if path_follows[current_cam].progress_ratio >= 1.0:
			current_cam += 1
			if current_cam >= cameras.size():
				current_cam = 0
			path_follows[current_cam].progress_ratio = 0.0
			cameras[current_cam].make_current()
