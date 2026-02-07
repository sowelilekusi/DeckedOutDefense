class_name FlowNodeVisualiser
extends StaticBody3D

var data: FlowNodeData
var connections: Array[FlowNodeVisualiser]
var visualisers: Array[Node3D]
var visual_scene: PackedScene = preload("res://Scenes/FlowField/cube2.tscn")
var best_path: FlowNodeVisualiser : 
	get():
		return best_path
	set(value):
		set_connector_color(best_path, Color.DARK_GRAY)
		best_path = value
		set_connector_color(best_path, Color.DARK_GREEN)


func setup_connection_visualisers() -> void:
	visualisers = []
	for node: FlowNodeVisualiser in connections:
		var visual: Node3D = visual_scene.instantiate()
		add_child(visual)
		visual.owner = self
		visualisers.append(visual)
		set_connector_color(node, Color.WEB_GRAY)


@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if visible:
		for i: int in connections.size():
			var distance: float = global_position.distance_to(connections[i].global_position)
			visualisers[i].scale = Vector3(0.3, 0.3, 1.0 * (distance / 2.0))
			visualisers[i].position = to_local(connections[i].global_position) / 4.0
			if distance >= 0.05:
				visualisers[i].look_at(connections[i].global_position)


func set_color(new_color: Color) -> void:
	$flow_node/Sphere.material_override.albedo_color = new_color


func set_connector_color(node: FlowNodeVisualiser, new_color: Color) -> void:
	if visible:
		var i: int = connections.find(node)
		visualisers[i].get_child(0).material_override.albedo_color = new_color


func add_connection(node: FlowNodeVisualiser) -> void:
	if !connections.has(node):
		var visual: Node3D = visual_scene.instantiate()
		add_child(visual)
		visual.owner = self
		connections.append(node)
		visualisers.append(visual)
		set_connector_color(node, Color.WEB_GRAY)


func remove_connection(node: FlowNodeVisualiser) -> void:
	if connections.has(node):
		var i: int = connections.find(node)
		visualisers.pop_at(i).queue_free()
		connections.remove_at(i)
