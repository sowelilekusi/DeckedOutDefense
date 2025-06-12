class_name FlowField extends Node3D

signal path_updated()

@export var flow_node_scene: PackedScene
@export var nodes: Array[FlowNode] = []
@export var goals: Array[FlowNode] = []
@export var starts: Array[FlowNode] = []
@export var nodes_visible: bool = false


func _ready() -> void:
	if !nodes_visible:
		for node: FlowNode in nodes:
			node.visible = false


func _process(delta: float) -> void:
	if !nodes_visible:
		return
	for node: FlowNode in nodes:
		if node.traversable and node.buildable:
			node.set_color(Color.WEB_GRAY)
		elif node.traversable and !node.buildable:
			node.set_color(Color.CORAL)
		else:
			node.set_color(Color.BLACK)
		if goals.has(node):
			node.set_color(Color.BLUE)
		if starts.has(node):
			node.set_color(Color.PINK)
		if magic_node:
			magic_node.set_color(Color.DEEP_PINK)


func get_closest_traversable_point(pos: Vector3) -> FlowNode:
	var closest_point: FlowNode = null
	var closest_dist: float = 100000.0
	for node: FlowNode in nodes:
		if node.traversable and node.global_position.distance_to(pos) < closest_dist:
			closest_dist = node.global_position.distance_to(pos)
			closest_point = node
	return closest_point


func get_closest_point_point(pos: Vector3) -> FlowNode:
	var closest_point: FlowNode = null
	var closest_dist: float = 100000.0
	for node: FlowNode in nodes:
		if node.global_position.distance_to(pos) < closest_dist:
			closest_dist = node.global_position.distance_to(pos)
			closest_point = node
	return closest_point


func get_closest_buildable_point(pos: Vector3) -> FlowNode:
	var closest_point: FlowNode = null
	var closest_dist: float = 100000.0
	for node: FlowNode in nodes:
		if node.buildable and node.global_position.distance_to(pos) < closest_dist:
			closest_dist = node.global_position.distance_to(pos)
			closest_point = node
	return closest_point


func test_traversability() -> bool:
	for node: FlowNode in starts:
		while node.best_path != null:
			if node.best_path.traversable:
				node = node.best_path
			else:
				return false
	return true


func iterate_search(search_frontier: Array[FlowNode], reached: Array[FlowNode]) -> void:
	var current: FlowNode = search_frontier.pop_front()
	for node: FlowNode in current.connections:
		if !reached.has(node):
			reached.append(node)
			if node.traversable:
				search_frontier.append(node)
			node.best_path = current


func calculate() -> void:
	var reached: Array[FlowNode] = []
	var search_frontier: Array[FlowNode] = []
	for node: FlowNode in goals:
		node.best_path = null
		reached.append(node)
		search_frontier.append(node)
	while search_frontier.size() > 0:
		iterate_search(search_frontier, reached)


var magic_node: FlowNode = null
func traversable_after_blocking_point(point: FlowNode) -> bool:
	magic_node = null
	var reached: Array[FlowNode] = [point]
	var search_frontier: Array[FlowNode] = []
	for node: FlowNode in point.connections:
		if node.best_path == point and node.traversable:
			reached.append(node)
			search_frontier.append(node)
	if search_frontier.size() == 0: # if no neighbors rely on this node, then we're all good
		return true
	while search_frontier.size() > 0:
		var current: FlowNode = search_frontier.pop_front()
		for node: FlowNode in current.connections:
			if !reached.has(node):
				if node.traversable and node.best_path != node and !reached.has(node.best_path):
					#if we havent already seen the node this neighbor goes to,
					#then all our searched nodes could swap to go this direction
					#and the path would still be traversable
					magic_node = node
					return true
				reached.append(node)
				if node.traversable:
					search_frontier.append(node)
	return false


## Connects many nodes to a single single node, if any connections already
## exist, this function disconnects them instead
func connect_many_nodes(common_node: FlowNode, child_nodes: Array[FlowNode]) -> void:
	for node: FlowNode in child_nodes:
		if common_node.connections.has(node):
			disconnect_nodes(common_node, node)
		else:
			connect_nodes(common_node, node)


func toggle_goal(nodes_to_toggle: Array[FlowNode]) -> void:
	for node: FlowNode in nodes_to_toggle:
		if goals.has(node):
			goals.erase(node)
		else:
			goals.append(node)


func toggle_start(nodes_to_toggle: Array[FlowNode]) -> void:
	for node: FlowNode in nodes_to_toggle:
		if starts.has(node):
			starts.erase(node)
		else:
			starts.append(node)


func toggle_traversable(node: FlowNode) -> bool:
	node.traversable = !node.traversable
	calculate()
	#TODO: technically the path only changed if the new path IS traversable
	path_updated.emit()
	return test_traversability()


func toggle_buildable(node: FlowNode) -> void:
	node.buildable = !node.buildable


func create_node(pos: Vector3 = Vector3.ZERO) -> FlowNode:
	var node: FlowNode = flow_node_scene.instantiate()
	node.position = pos
	node.set_color(Color.WEB_GRAY)
	nodes.append(node)
	add_child(node)
	node.owner = self
	return node


func delete_node(node: FlowNode) -> void:
	for neighbor: FlowNode in node.connections:
		node.remove_connection(neighbor)
	nodes.erase(node)
	node.queue_free()


func connect_nodes(node1: FlowNode, node2: FlowNode) -> void:
	if node1 != node2:
		node1.add_connection(node2)
		node2.add_connection(node1)


func disconnect_nodes(node1: FlowNode, node2: FlowNode) -> void:
	if node1 != node2:
		node1.remove_connection(node2)
		node2.remove_connection(node1)


func create_grid(x_size: int, y_size: int, gap: float) -> void:
	var grid: Array[Array] = []
	for x: int in x_size:
		var row: Array[FlowNode] = []
		for y: int in y_size:
			#var start_pos: Vector3 = Vector3.ZERO - (Vector3(gap * x_size, 0, gap * y_size) / 2.0)
			var point_position: Vector3 = Vector3((x - floori(x_size / 2.0)) * gap, 0, (y - floori(y_size / 2.0)) * gap)
			#point_position += global_position
			#row.append(create_node(start_pos + Vector3(gap * x, 0, gap * y)))
			row.append(create_node(point_position))
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
