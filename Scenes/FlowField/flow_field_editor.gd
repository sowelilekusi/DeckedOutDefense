class_name FlowFieldEditor
extends Node

@export var flow_field: FlowField


func create_grid(x_size: int, y_size: int, gap: float) -> Array[FlowNodeData]:
	flow_field.data.grids += 1
	var grid_id: int = flow_field.data.grids
	var grid: Array[Array] = []
	var created_nodes: Array[FlowNodeData] = []
	
	for x: int in x_size:
		var row: Array[FlowNodeData] = []
		for y: int in y_size:
			var point_position: Vector3 = Vector3((x - floori(x_size / 2.0)) * gap, 0, (y - floori(y_size / 2.0)) * gap)
			var created_node: FlowNodeData = create_node(point_position, grid_id, x, y)
			created_nodes.append(created_node)
			row.append(created_node)
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
	return created_nodes


func create_node(pos: Vector3 = Vector3.ZERO, grid_id: int = -1, grid_x: int = 0, grid_y: int = 0) -> FlowNodeData:
	var node: FlowNodeData = FlowNodeData.new()
	node.node_id = flow_field.data.nodes.size()
	node.grid_id = grid_id
	node.grid_x = grid_x
	node.grid_y = grid_y
	node.position = pos
	flow_field.data.nodes.append(node)
	return node


func delete_node(node: FlowNodeData) -> void:
	for neighbor: FlowNodeData in node.connections:
		disconnect_nodes(node, neighbor)
	flow_field.data.nodes.erase(node)


func connect_nodes(a: FlowNodeData, b: FlowNodeData) -> void:
	if a != b:
		if a.connected_nodes.has(b):
			a.connected_nodes.append(b)
		if b.connected_nodes.has(a):
			b.add_connection(a)


func disconnect_nodes(a: FlowNodeData, b: FlowNodeData) -> void:
	if a != b:
		if a.connected_nodes.has(b):
			a.connected_nodes.erase(b)
		if b.connected_nodes.has(a):
			b.connected_nodes.erase(a)
