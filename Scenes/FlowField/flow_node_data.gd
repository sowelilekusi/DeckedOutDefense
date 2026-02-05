class_name FlowNodeData
extends Resource

enum NodeType {
	STANDARD = 0,
	START = 1,
	GOAL = 2,
}

@export var node_id: int = -1
@export var position: Vector3 = Vector3.ZERO
@export var type: NodeType = NodeType.STANDARD
@export var buildable: bool = true
@export var connected_nodes: Array[FlowNodeData]
@export var in_grid: bool = false
@export var grid_id: int = -1
@export var grid_x: int = 0
@export var grid_y: int = 0


#This function cannot fill in the connection information until a complete set
#of nodes have been loaded and can be looped over
static func from_dict(dict: Dictionary) -> FlowNodeData:
	var data: FlowNodeData = FlowNodeData.new()
	data.node_id = dict["node_id"]
	data.position.x = dict["position_x"]
	data.position.y = dict["position_y"]
	data.position.z = dict["position_z"]
	data.type = dict["type"]
	data.buildable = dict["buildable"]
	data.in_grid = dict["in_grid"]
	data.grid_id = dict["grid_id"]
	data.grid_x = dict["grid_x"]
	data.grid_y = dict["grid_y"]
	return data


func populate_connections(dict: Dictionary, node_array: Array[FlowNodeData]) -> void:
	var connections_array: Array = dict["connected_nodes"]
	for x: float in connections_array:
		for y: FlowNodeData in node_array:
			if y.node_id == int(x):
				connected_nodes.append(y)


func to_dict() -> Dictionary:
	var dict: Dictionary = {}
	var connections: Array[int] = []
	for node: FlowNodeData in connected_nodes:
		connections.append(node.node_id)
	dict["connected_nodes"] = connections
	dict["node_id"] = node_id
	dict["position_x"] = position.x
	dict["position_y"] = position.y
	dict["position_z"] = position.z
	dict["type"] = type
	dict["buildable"] = buildable
	dict["in_grid"] = in_grid
	dict["grid_id"] = grid_id
	dict["grid_x"] = grid_x
	dict["grid_y"] = grid_y
	return dict
