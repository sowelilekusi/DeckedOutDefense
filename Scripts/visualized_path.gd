extends Path3D
class_name VisualizedPath

var visual_scene = preload("res://Scenes/path_visual_thing.tscn")
var length := 0.0
var visualizer_points = []

func spawn_visualizer_points() -> void:
	var new_length = curve.get_baked_length()
	for x in new_length - length:
		var point = visual_scene.instantiate()
		visualizer_points.append(point)
		add_child(point)
	length = new_length
	for x in visualizer_points.size():
		visualizer_points[x].progress_ratio = float(x) / visualizer_points.size()


func disable_visualization():
	for x in visualizer_points:
		x.set_world_visible(false)


func enable_visualization():
	for x in visualizer_points:
		x.set_world_visible(true)
