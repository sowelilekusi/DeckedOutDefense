class_name FlowFieldEditor
extends Node

@export var flow_field: FlowField


func create_grid(x: int, y: int, gap: int) -> Array[FlowNode]:
	#return flow_field.create_grid(x, y, gap)
	return []


func create_node(pos: Vector3 = Vector3.ZERO, grid_id: int = -1, grid_x: int = 0, grid_y: int = 0) -> FlowNode:
	return flow_field.create_node(pos, grid_id, grid_x, grid_y)
