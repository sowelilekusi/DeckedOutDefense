class_name FlowFieldData
extends RefCounted

var nodes: Array[FlowNodeData]
var grids: int = 0


func to_dict() -> Dictionary:
	var dict: Dictionary = {}
	for node: FlowNodeData in nodes:
		dict[node.node_id] = node.to_dict()
	dict["grids"] = grids
	return dict


static func from_dict(dict: Dictionary) -> FlowFieldData:
	var flow: FlowFieldData = FlowFieldData.new()
	var unpopulated: Dictionary[FlowNodeData, Dictionary] = {}
	for key: String in dict.keys():
		if key.is_valid_int():
			var data: FlowNodeData = FlowNodeData.from_dict(dict[key])
			flow.nodes.append(data)
			unpopulated[data] = dict[key]
	for key: FlowNodeData in unpopulated.keys():
		key.populate_connections(unpopulated[key], flow.nodes)
	flow.grids = dict["grids"]
	return flow
