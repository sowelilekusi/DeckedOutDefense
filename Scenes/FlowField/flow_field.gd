class_name FlowField
extends Node3D

signal path_updated()

@export var start_points: Array[Node3D]
@export var goal_points: Array[Node3D]

var start_nodes: Array[FlowNodeData]
var goal_nodes: Array[FlowNodeData]
var magic_node: FlowNodeData
var data: FlowFieldData :
	get():
		return data
	set(value):
		data = value
		for node: FlowNodeData in data.nodes:
			if node.type == FlowNodeData.NodeType.START:
				start_nodes.append(node)
			if node.type == FlowNodeData.NodeType.GOAL:
				goal_nodes.append(node)


func get_closest_point(pos: Vector3, traversable_required: bool = false, buildable_required: bool = false) -> FlowNodeData:
	var closest_point: FlowNodeData = null
	var closest_dist: float = 100000.0
	for node: FlowNodeData in data.nodes:
		if node.position.distance_to(pos) < closest_dist:
			if !traversable_required or node.traversable:
				if !buildable_required or node.buildable:
					closest_dist = node.position.distance_to(pos)
					closest_point = node
	return closest_point


func test_traversability() -> bool:
	for node: FlowNodeData in start_nodes:
		while node.best_path != null:
			if node.best_path.traversable:
				node = node.best_path
			else:
				return false
	return true


func iterate_search(search_frontier: Array[FlowNodeData], reached: Array[FlowNodeData]) -> void:
	var current: FlowNodeData = search_frontier.pop_front()
	for node: FlowNodeData in current.connected_nodes:
		if !reached.has(node):
			reached.append(node)
			if node.traversable:
				search_frontier.append(node)
			node.best_path = current


func calculate() -> void:
	var reached: Array[FlowNodeData] = []
	var search_frontier: Array[FlowNodeData] = []
	for node: FlowNodeData in goal_nodes:
		node.best_path = null
		reached.append(node)
		search_frontier.append(node)
	while search_frontier.size() > 0:
		iterate_search(search_frontier, reached)


func traversable_after_blocking_point(point: FlowNodeData) -> bool:
	magic_node = null
	var reached: Array[FlowNodeData] = [point]
	var search_frontier: Array[FlowNodeData] = []
	for node: FlowNodeData in point.connected_nodes:
		if node.best_path == point and node.traversable:
			reached.append(node)
			search_frontier.append(node)
	if search_frontier.size() == 0: # if no neighbors rely on this node, then we're all good
		return true
	while search_frontier.size() > 0:
		var current: FlowNodeData = search_frontier.pop_front()
		for node: FlowNodeData in current.connected_nodes:
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


func toggle_goal(nodes_to_toggle: Array[FlowNodeData]) -> void:
	for node: FlowNodeData in nodes_to_toggle:
		if goal_nodes.has(node):
			goal_nodes.erase(node)
		else:
			goal_nodes.append(node)


func toggle_start(nodes_to_toggle: Array[FlowNodeData]) -> void:
	for node: FlowNodeData in nodes_to_toggle:
		if start_nodes.has(node):
			start_nodes.erase(node)
		else:
			start_nodes.append(node)


func toggle_traversable(node: FlowNodeData) -> bool:
	node.traversable = !node.traversable
	calculate()
	#TODO: technically the path only changed if the new path IS traversable
	path_updated.emit()
	return test_traversability()


func toggle_buildable(node: FlowNodeData) -> void:
	node.buildable = !node.buildable
