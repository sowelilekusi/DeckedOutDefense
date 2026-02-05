class_name FlowNodeData
extends Resource

enum NodeType {
	STANDARD = 0,
	START = 1,
	GOAL = 2,
}

@export var position: Vector3 = Vector3.ZERO
@export var type: NodeType = NodeType.STANDARD
@export var buildable: bool = true
@export var connected_nodes: Array[FlowNodeData]
@export var in_grid: bool = false
@export var grid_id: int = -1
@export var grid_x: int = 0
@export var grid_y: int = 0
