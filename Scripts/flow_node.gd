class_name FlowNode extends StaticBody3D

var connections: Array[FlowNode]
var visualisers: Array[CSGBox3D]
var traversable: bool = true
var best_path: FlowNode : 
	get():
		return best_path
	set(value):
		set_connector_color(best_path, Color.DARK_GRAY)
		best_path = value
		set_connector_color(best_path, Color.DARK_GREEN)


func _process(delta: float) -> void:
	for i: int in connections.size():
		var distance: float = global_position.distance_to(connections[i].global_position)
		visualisers[i].size = Vector3(0.3, 0.3, 1.0 * (distance / 2.0))
		visualisers[i].position = to_local(connections[i].global_position) / 4.0
		if distance >= 0.05:
			visualisers[i].look_at(connections[i].global_position)


func set_color(new_color: Color) -> void:
	$CSGSphere3D.material.albedo_color = new_color


func set_connector_color(node: FlowNode, new_color: Color) -> void:
	var i: int = connections.find(node)
	visualisers[i].material.albedo_color = new_color


func add_connection(node: FlowNode) -> void:
	if !connections.has(node):
		var visual: CSGBox3D = CSGBox3D.new()
		visual.material = StandardMaterial3D.new()
		visual.material.resource_local_to_scene = true
		visual.material.albedo_color = Color.DARK_GRAY
		add_child(visual)
		connections.append(node)
		visualisers.append(visual)


func remove_connection(node: FlowNode) -> void:
	if connections.has(node):
		var i: int = connections.find(node)
		visualisers.pop_at(i).queue_free()
		connections.remove_at(i)
