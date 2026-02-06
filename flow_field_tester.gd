class_name FlowFieldTester extends Control

var flow_field: FlowField
var flow_field_tool: FlowFieldEditor
var node_boxes: Array[ColorRect]
var offset: Vector2
var hovered: ColorRect


func _ready() -> void:
	flow_field = FlowField.new()
	var flow_field_data: FlowFieldData = FlowFieldData.new()
	flow_field.data_file = flow_field_data
	flow_field_tool = FlowFieldEditor.new()
	add_child(flow_field)
	add_child(flow_field_tool)
	flow_field_tool.flow_field = flow_field
	flow_field_tool.create_grid(10, 10, 1)
	var furthest_negative_vector: Vector2 = Vector2.ZERO
	for node: FlowNode in flow_field.nodes:
		var box: ColorRect = ColorRect.new()
		box.position = Vector2(node.position.x * 15.0, node.position.z * 15.0)
		if node.position.x * 15.0 < furthest_negative_vector.x:
			furthest_negative_vector.x = node.position.x * 15.0
		if node.position.z * 15.0 < furthest_negative_vector.y:
			furthest_negative_vector.y = node.position.z * 15.0
		box.size = Vector2(10.0, 10.0)
		box.mouse_entered.connect(box_hovered.bind(box))
		node_boxes.append(box)
		$CanvasLayer.add_child(box)
	print(furthest_negative_vector)
	$CanvasLayer.offset = -furthest_negative_vector
	update_colors()


func box_hovered(box: ColorRect) -> void:
	hovered = box
	update_colors()


func update_colors() -> void:
	var x: int = 0
	for box: ColorRect in node_boxes:
		if flow_field.nodes[x].traversable:
			box.color = Color.GREEN
		else:
			box.color = Color.RED
		if box == hovered:
			box.color = Color.AQUAMARINE
		x += 1


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 0:
		pass
