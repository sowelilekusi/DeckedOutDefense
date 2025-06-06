class_name FlowField extends Node3D

@export var flow_node_scene: PackedScene
var nodes: Array[FlowNode] = []
var hover: FlowNode = null
var selected: Array[FlowNode] = []
var vector_dirty: bool = false
var goals: Array[FlowNode] = []
var reached: Array[FlowNode] = []
var search_frontier: Array[FlowNode] = []


func _process(delta: float) -> void:
	if $CameraFocus/Camera3D/RayCast3D.is_colliding() and !hover:
		hover = $CameraFocus/Camera3D/RayCast3D.get_collider()
		hover.set_color(Color.RED)
	if hover and !$CameraFocus/Camera3D/RayCast3D.is_colliding():
		hover.set_color(Color.WEB_GRAY)
		hover = null
		if selected.size() > 0:
			for node: FlowNode in selected:
				node.set_color(Color.GREEN)
		if goals.size() > 0:
			for node: FlowNode in goals:
				node.set_color(Color.BLUE)
	if selected.size() == 1 and vector_dirty:
		$HBoxContainer.visible = true
		$HBoxContainer/x.text = str(selected[0].global_position.x)
		$HBoxContainer/y.text = str(selected[0].global_position.y)
		$HBoxContainer/z.text = str(selected[0].global_position.z)
		vector_dirty = false
	elif selected.size() != 1:
		$HBoxContainer.visible = false
	
	var y: float = Input.get_axis("Move Forward", "Move Backward")
	var x: float = Input.get_axis("Move Left", "Move Right")
	$CameraFocus.position += Vector3(x, 0, y) * delta * 10


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var from: Vector3 = $CameraFocus/Camera3D.project_ray_origin(event.position)
		var to: Vector3 = $CameraFocus/Camera3D.project_local_ray_normal(event.position)
		$CameraFocus/Camera3D/RayCast3D.global_position = from
		$CameraFocus/Camera3D/RayCast3D.target_position = to * 1000.0
	if event is InputEventMouseButton and event.button_index == 1 and hover:
		if !selected.has(hover):
			selected.append(hover)
			vector_dirty = true
	if event is InputEventMouseButton and event.button_index == 2 and selected.size() > 0:
		for node: FlowNode in selected:
			node.set_color(Color.WEB_GRAY)
		selected = []


func _on_button_pressed() -> void:
	create_node()


func iterate_search() -> void:
	var current: FlowNode = search_frontier.pop_front()
	for node: FlowNode in current.connections:
		if !reached.has(node):
			reached.append(node)
			if node.traversable:
				search_frontier.append(node)
			node.best_path = current
			#current.set_connector_color(node, Color.DARK_GREEN)


func calculate() -> void:
	#if search_frontier.size() > 0:
	#	iterate_search()
	#else:
	reached = []
	search_frontier = []
	for node: FlowNode in goals:
		search_frontier.append(node)
		reached.append(node)
	while search_frontier.size() > 0:
		iterate_search()


func _on_x_text_changed() -> void:
	selected[0].global_position.x = float($HBoxContainer/x.text)


func _on_y_text_changed() -> void:
	selected[0].global_position.y = float($HBoxContainer/y.text)


func _on_z_text_changed() -> void:
	selected[0].global_position.z = float($HBoxContainer/z.text)


func _on_button_3_pressed() -> void:
	if selected.size() == 2:
		if selected[0].connections.has(selected[1]):
			disconnect_nodes(selected[0], selected[1])
		else:
			connect_nodes(selected[0], selected[1])


func _on_button_4_pressed() -> void:
	for node: FlowNode in selected:
		if goals.has(node):
			goals.erase(node)
			node.set_color(Color.GREEN)
		else:
			goals.append(node)
			node.set_color(Color.BLUE)


func _on_button_5_pressed() -> void:
	if selected.size() == 1:
		var node: FlowNode = create_node(selected[0].position)
		node.add_connection(selected[0])
		selected[0].add_connection(node)
		selected[0].set_color(Color.WEB_GRAY)
		selected[0] = node


func create_node(pos: Vector3 = Vector3.ZERO) -> FlowNode:
	var node: FlowNode = flow_node_scene.instantiate()
	node.position = pos
	nodes.append(node)
	add_child(node)
	return node


func connect_nodes(node1: FlowNode, node2: FlowNode) -> void:
	if node1 != node2:
		node1.add_connection(node2)
		node2.add_connection(node1)


func disconnect_nodes(node1: FlowNode, node2: FlowNode) -> void:
	if node1 != node2:
		node1.remove_connection(node2)
		node2.remove_connection(node1)


func _on_button_2_pressed(x_size: int = 9, y_size: int = 9) -> void:
	var grid: Array[Array] = []
	for x: int in x_size:
		var row: Array[FlowNode] = []
		for y: int in y_size:
			var start_pos: Vector3 = Vector3.ZERO - (Vector3(1.5 * x_size, 0, 1.5 * y_size) / 2.0)
			row.append(create_node(start_pos + Vector3(1.5 * x, 0, 1.5 * y)))
		grid.append(row)
	for x: int in grid.size():
		for y: int in grid[x].size():
			if y > 0:
				connect_nodes(grid[x][y], grid[x][y - 1])
			if x > 0:
				connect_nodes(grid[x][y], grid[x - 1][y])
			if y < grid[x].size() - 1:
				connect_nodes(grid[x][y], grid[x][y + 1])
			if x < grid.size() - 1:
				connect_nodes(grid[x][y], grid[x + 1][y])


func _on_button_6_pressed() -> void:
	for node: FlowNode in selected:
		node.traversable = !node.traversable
