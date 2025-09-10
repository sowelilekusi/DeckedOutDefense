class_name FlowFieldTool
extends Node

@export var flow_field: FlowField
@export var raycast: RayCast3D
@export var project_raycast: RayCast3D
@export var camera: Camera3D
@export var camera_pivot: Node3D
@export var position_field: HBoxContainer
@export var x_field: LineEdit
@export var y_field: LineEdit
@export var z_field: LineEdit
@export var x_size_field: LineEdit
@export var y_size_field: LineEdit
@export var gap_field: LineEdit
@export var save_path: LineEdit

var hover: FlowNode = null
var selected: Array[FlowNode] = []
var vector_dirty: bool = false


func _ready() -> void:
	camera.make_current()


func _process(delta: float) -> void:
	if raycast.is_colliding() and (!hover or hover != raycast.get_collider()):
		hover = raycast.get_collider()
	if hover and !raycast.is_colliding():
		hover = null
	if selected.size() == 1 and vector_dirty:
		position_field.visible = true
		x_field.text = str(selected[0].global_position.x)
		y_field.text = str(selected[0].global_position.y)
		z_field.text = str(selected[0].global_position.z)
		vector_dirty = false
	elif selected.size() != 1:
		position_field.visible = false
	
	for node: FlowNode in flow_field.nodes:
		if node.traversable and node.buildable:
			node.set_color(Color.WEB_GRAY)
		elif node.traversable and !node.buildable:
			node.set_color(Color.CORAL)
		else:
			node.set_color(Color.BLACK)
		if flow_field.goal_nodes.has(node):
			node.set_color(Color.BLUE)
		if flow_field.start_nodes.has(node):
			node.set_color(Color.PINK)
		if selected.has(node):
			node.set_color(Color.GREEN)
		if node == hover:
			node.set_color(Color.RED)
	
	var y: float = Input.get_axis("Move Forward", "Move Backward")
	var x: float = Input.get_axis("Move Left", "Move Right")
	camera_pivot.position += Vector3(x, 0, y) * delta * 10


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var from: Vector3 = camera.project_ray_origin(event.position)
		var to: Vector3 = camera.project_local_ray_normal(event.position)
		raycast.global_position = from
		raycast.target_position = to * 1000.0
	if event is InputEventMouseButton and event.button_index == 1 and hover:
		if !selected.has(hover):
			selected.append(hover)
			vector_dirty = true
	if event is InputEventMouseButton and event.button_index == 2 and selected.size() > 0:
		selected = []
	if event is InputEventKey and event.keycode == KEY_UP:
		var vector: Vector3 = camera.position - camera_pivot.position
		vector = vector.normalized()
		camera.position += vector
	if event is InputEventKey and event.keycode == KEY_DOWN:
		var vector: Vector3 = camera.position - camera_pivot.position
		vector = vector.normalized()
		camera.position -= vector


func _on_x_field_changed(text: String) -> void:
	selected[0].global_position.x = float(text)


func _on_y_field_changed(text: String) -> void:
	selected[0].global_position.y = float(text)


func _on_z_field_changed(text: String) -> void:
	selected[0].global_position.z = float(text)


func _on_create_button_pressed() -> void:
	flow_field.create_node()


func _on_generate_grid_button_pressed() -> void:
	flow_field.create_grid(int(x_size_field.text), int(y_size_field.text), float(gap_field.text))
	selected.append_array(flow_field.nodes)


func _on_calculate_button_pressed() -> void:
	flow_field.calculate()


func _on_connect_button_pressed() -> void:
	flow_field.connect_many_nodes(selected[0], selected.slice(1, selected.size()))


func _on_mark_goal_button_pressed() -> void:
	flow_field.toggle_goal(selected)
	selected = []
	vector_dirty = true


func _on_mark_start_button_pressed() -> void:
	flow_field.toggle_start(selected)
	selected = []
	vector_dirty = true


func _on_extrude_button_pressed() -> void:
	if selected.size() == 1:
		var node: FlowNode = flow_field.create_node(selected[0].position)
		node.add_connection(selected[0])
		selected[0].add_connection(node)
		selected[0].set_color(Color.WEB_GRAY)
		selected = []
		selected.append(node)
		vector_dirty = true


func _on_toggle_traversable_button_pressed() -> void:
	for node: FlowNode in selected:
		if !flow_field.toggle_traversable(node):
			flow_field.toggle_traversable(node)
			selected = []
			return
	selected = []


func _on_toggle_buildable_button_pressed() -> void:
	for node: FlowNode in selected:
		flow_field.toggle_buildable(node)


#TODO: This doesnt work as you'd expect because of physics frames
func _on_project_downwards_button_pressed() -> void:
	for node: FlowNode in selected: 
		project_raycast.global_position = node.global_position + Vector3.UP
		project_raycast.target_position = Vector3.DOWN * 100.0
		await get_tree().physics_frame
		await get_tree().physics_frame
		await get_tree().physics_frame
		await get_tree().physics_frame
		if project_raycast.is_colliding():
			node.global_position = project_raycast.get_collision_point()


func _on_save_button_pressed() -> void:
	var new_flow_field_data: FlowFieldData = FlowFieldData.new()
	var dict: Dictionary[FlowNode, FlowNodeData] = {}
	for node: FlowNode in flow_field.nodes:
		var new_flow_node_data: FlowNodeData = FlowNodeData.new()
		new_flow_node_data.position = node.global_position
		new_flow_node_data.buildable = node.buildable
		if flow_field.start_nodes.has(node):
			new_flow_node_data.type = FlowNodeData.NodeType.START
		elif flow_field.goal_nodes.has(node):
			new_flow_node_data.type = FlowNodeData.NodeType.GOAL
		else:
			new_flow_node_data.type = FlowNodeData.NodeType.STANDARD
		dict[node] = new_flow_node_data
	for node: FlowNode in flow_field.nodes:
		var flow_node_data: FlowNodeData = dict[node]
		for neighbor: FlowNode in node.connections:
			flow_node_data.connected_nodes.append(dict[neighbor])
		new_flow_field_data.nodes.append(flow_node_data)
	ResourceSaver.save(new_flow_field_data, save_path.text)


func _on_load_button_pressed() -> void:
	if ResourceLoader.exists(save_path.text):
		var resource: Resource = ResourceLoader.load(save_path.text)
		if resource is FlowFieldData:
			flow_field.load_from_data(resource)
