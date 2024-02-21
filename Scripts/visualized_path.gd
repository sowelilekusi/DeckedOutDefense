class_name VisualizedPath extends Path3D

var visual_scene: PackedScene = preload("res://Scenes/path_visual_thing.tscn")
var length: float = 0.0
var visualizer_points: Array = []


func spawn_visualizer_points() -> void:
	var new_length: float = curve.get_baked_length()
	for x: int in floori(new_length) - visualizer_points.size():
		var point: PathFollow3D = visual_scene.instantiate()
		visualizer_points.append(point)
		add_child(point)
	length = new_length
	#print(str(int(length)) + " / " + str(visualizer_points.size()) + ", diff: " + str(visualizer_points.size() - length))
	for x: int in visualizer_points.size():
		visualizer_points[x].progress_ratio = float(x) / visualizer_points.size()


func disable_visualization() -> void:
	for x: PathFollow3D in visualizer_points:
		x.set_world_visible(false)


func enable_visualization() -> void:
	for x: PathFollow3D in visualizer_points:
		x.set_world_visible(true)
