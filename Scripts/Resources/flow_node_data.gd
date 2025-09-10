class_name FlowNodeData
extends Resource

enum NodeType {
	STANDARD = 0,
	START = 1,
	GOAL = 2,
}

@export var position: Vector3
@export var type: NodeType
@export var buildable: bool
@export var connected_nodes: Array[FlowNodeData]
