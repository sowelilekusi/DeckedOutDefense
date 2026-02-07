class_name FlowFieldTool
extends Node

@export_group("Basic Function")
@export var zone_list: Array[PackedScene]
@export var zone_holder: Node3D
@export var visualiser_scene: PackedScene

@export_group("Flow Field Editor")
@export var raycast: RayCast3D
@export var project_raycast: RayCast3D
@export var camera: Camera3D
@export var camera_pivot: Node3D
@export var position_field: HBoxContainer
@export var position_x: LineEdit
@export var position_y: LineEdit
@export var position_z: LineEdit
@export var x_field: LineEdit
@export var y_field: LineEdit
@export var z_field: LineEdit
@export var x_size_field: LineEdit
@export var y_size_field: LineEdit
@export var gap_field: LineEdit
@export var save_path: LineEdit

var flow_field: FlowField
var visualisers: Dictionary[FlowNodeData, FlowNodeVisualiser]
var hover: FlowNodeVisualiser = null
var selected: Array[FlowNodeVisualiser] = []
var vector_dirty: bool = false
var editing: bool = false
var selected_zone: int = -1
var level: Level
var radius: float = 0
var up_angle: float = 0
var rotate_held: bool = false
var flow_field_editor: FlowFieldEditor
var path_vfx: PathVFX


func _ready() -> void:
	flow_field_editor = FlowFieldEditor.new()
	add_child(flow_field_editor)
	var i: int = 0
	for zone: PackedScene in zone_list:
		i += 1
		$VBoxContainer2/OptionButton.add_item("Zone " + str(i))
	$VBoxContainer2/OptionButton.select(0)
	$VBoxContainer2/OptionButton.item_selected.connect(select_zone)
	_on_trash_button_pressed()
	path_vfx = PathVFX.new()
	path_vfx.line_width = 0.4
	path_vfx.material = load("res://path_material.tres")
	add_child(path_vfx)


func setup_visualisers_from_flow_field_data(data: FlowFieldData) -> void:
	for visualiser: FlowNodeVisualiser in visualisers.keys():
		visualiser.queue_free()
	visualisers = {}
	for node: FlowNodeData in data.nodes:
		add_visual(node)
	for node: FlowNodeData in visualisers.keys():
		add_visual_connections(node)


func add_visual(data: FlowNodeData) -> void:
	var visual: FlowNodeVisualiser = visualiser_scene.instantiate() as FlowNodeVisualiser
	visual.data = data
	visual.position = data.position
	add_child(visual)
	visualisers[data] = visual


func add_visual_connections(data: FlowNodeData) -> void:
	var connections: Array[FlowNodeVisualiser] = []
	for node: FlowNodeData in data.connected_nodes:
		connections.append(visualisers[node])
	visualisers[data].connections = connections
	visualisers[data].setup_connection_visualisers()


func select_zone(zone_index: int) -> void:
	selected_zone = zone_index


func load_zone() -> void:
	_on_trash_button_pressed()
	if level:
		level.queue_free()
	level = zone_list[selected_zone].instantiate() as Level
	level.flow_field = flow_field
	zone_holder.add_child(level)
	camera.make_current()
	editing = true


func _process(delta: float) -> void:
	if editing:
		if raycast.is_colliding() and (!hover or hover != raycast.get_collider()):
			hover = raycast.get_collider()
		if hover and !raycast.is_colliding():
			hover = null
		if selected.size() == 1 and vector_dirty:
			$Position/Button.visible = true
			position_field.visible = true
			x_field.text = str(selected[0].global_position.x)
			y_field.text = str(selected[0].global_position.y)
			z_field.text = str(selected[0].global_position.z)
			vector_dirty = false
		elif selected.size() > 1:
			$Position/Button.visible = false
			position_field.visible = true
		elif selected.size() < 1:
			position_field.visible = false
		
		set_node_colors()
		
		if Input.is_action_just_pressed("Secondary Fire"):
			rotate_held = true
		if Input.is_action_just_released("Secondary Fire"):
			rotate_held = false
		
		var y: float = Input.get_axis("Move Forward", "Move Backward")
		var x: float = Input.get_axis("Move Left", "Move Right")
		var input_vector: Vector2 = Input.get_vector("Move Left", "Move Right", "Move Forward", "Move Backward")

		var movement: Vector3 = ((camera_pivot.transform.basis.z * input_vector.y) + (camera_pivot.transform.basis.x * input_vector.x))
		var vec2: Vector2 = Vector2(movement.x, movement.z).normalized()
		camera_pivot.position += Vector3(vec2.x, 0.0, vec2.y) * delta * 30.0


func set_node_colors() -> void:
	for node: FlowNodeVisualiser in visualisers.values():
		if node.data.traversable and node.data.buildable:
			node.set_color(Color.WEB_GRAY)
		elif node.data.traversable and !node.data.buildable:
			node.set_color(Color.CORAL)
		else:
			node.set_color(Color.BLACK)
		if flow_field.goal_nodes.has(node.data):
			node.set_color(Color.BLUE)
		if flow_field.start_nodes.has(node.data):
			node.set_color(Color.PINK)
		if selected.has(node):
			node.set_color(Color.GREEN)
		if node == hover:
			node.set_color(Color.RED)


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
	
	if event is InputEventMouseButton and event.button_index == 5:
		zoom_in()
	
	if event is InputEventMouseButton and event.button_index == 4:
		zoom_out()
	
	if event is InputEventMouseMotion and rotate_held:
		camera_pivot.rotation.y -= (event.relative.x * get_viewport().get_final_transform().x.x) * (Data.preferences.mouse_sens / 10000.0) * (-1 if Data.preferences.invert_lookY else 1)
		up_angle -= (event.relative.y * get_viewport().get_final_transform().y.y) * (Data.preferences.mouse_sens / 10000.0) * (-1 if Data.preferences.invert_lookY else 1)
		up_angle = clamp(up_angle, deg_to_rad(-90), deg_to_rad(90))
		camera_pivot.rotation.x = up_angle


func zoom_out() -> void:
	camera.position.z -= 0.3


func zoom_in() -> void:
	camera.position.z += 0.3


func _on_x_field_changed(text: String) -> void:
	selected[0].global_position.x = float(text)


func _on_y_field_changed(text: String) -> void:
	selected[0].global_position.y = float(text)


func _on_z_field_changed(text: String) -> void:
	selected[0].global_position.z = float(text)


## Connects many nodes to a single single node, if any connections already
## exist, this function disconnects them instead
func connect_many_nodes(common_node: FlowNodeData, child_nodes: Array[FlowNodeData]) -> void:
	for node: FlowNodeData in child_nodes:
		if common_node.connections.has(node):
			flow_field_editor.disconnect_nodes(common_node, node)
		else:
			flow_field_editor.connect_nodes(common_node, node)


func set_position() -> void:
	for node: FlowNodeVisualiser in selected:
		var vector: Vector3 = Vector3(float(position_x.text), float(position_y.text), float(position_z.text))
		node.data.position = vector
		node.global_position = vector


func offset_position() -> void:
	for node: FlowNodeVisualiser in selected:
		var vector: Vector3 = Vector3(float(position_x.text), float(position_y.text), float(position_z.text))
		node.data.position += vector
		node.global_position += vector


func _on_create_button_pressed() -> void:
	add_visual(flow_field_editor.create_node())


func _on_generate_grid_button_pressed() -> void:
	for node: FlowNodeData in flow_field_editor.create_grid(int(x_size_field.text), int(y_size_field.text), float(gap_field.text)):
		add_visual(node)
		selected.append(node)
	create_grid_select_button(flow_field.data.grids)


func create_grid_select_button(grid: int) -> void:
	var button: Button = Button.new()
	button.text = "Grid " + str(grid)
	button.pressed.connect(select_in_grid.bind(grid))
	$VBoxContainer3.add_child(button)


func _on_calculate_button_pressed() -> void:
	flow_field.calculate()
	var points: Array[Vector3] = []
	var node: FlowNodeData = flow_field.get_closest_point(flow_field.start_nodes[0].position, true, false)
	points.append(node.position + Vector3(0, 0.1, 0))
	while node.best_path:
		node = node.best_path
		points.append(node.position + Vector3(0, 0.1, 0))
	path_vfx.path(points)


func _on_connect_button_pressed() -> void:
	flow_field.connect_many_nodes(selected[0], selected.slice(1, selected.size()))


func _on_mark_goal_button_pressed() -> void:
	for node: FlowNodeVisualiser in selected:
		flow_field.toggle_goal([node.data])
	selected = []
	vector_dirty = true


func _on_mark_start_button_pressed() -> void:
	for node: FlowNodeVisualiser in selected:
		flow_field.toggle_start([node.data])
	selected = []
	vector_dirty = true


func _on_extrude_button_pressed() -> void:
	if selected.size() == 1:
		var node: FlowNodeVisualiser = visualiser_scene.instantiate() as FlowNodeVisualiser
		add_child(node)
		node.data = flow_field.create_node(selected[0].position)
		node.add_connection(selected[0])
		selected[0].add_connection(node)
		selected[0].set_color(Color.WEB_GRAY)
		selected = []
		selected.append(node)
		vector_dirty = true


func _on_toggle_traversable_button_pressed() -> void:
	for node: FlowNodeVisualiser in selected:
		if !flow_field.toggle_traversable(node.data):
			flow_field.toggle_traversable(node.data)
			selected = []
			return
	selected = []


func _on_toggle_buildable_button_pressed() -> void:
	for node: FlowNodeVisualiser in selected:
		flow_field.toggle_buildable(node.data)


#TODO: This doesnt work as you'd expect because of physics frames
func _on_project_downwards_button_pressed() -> void:
	for node: FlowNodeVisualiser in selected: 
		project_raycast.position = node.position + Vector3.UP
		project_raycast.target_position = Vector3.DOWN * 100.0
		await get_tree().physics_frame
		await get_tree().physics_frame
		await get_tree().physics_frame
		await get_tree().physics_frame
		if project_raycast.is_colliding():
			node.position = project_raycast.get_collision_point()
			node.data.position = node.position


func _on_save_button_pressed() -> void:
	var string: String = JSON.stringify(flow_field.data.to_dict())
	var path: String = save_path.text + ".json"
	var dir: DirAccess = DirAccess.open("user://")
	if !dir.dir_exists("pathing_graphs"):
		dir.make_dir("pathing_graphs")
	dir.change_dir("pathing_graphs")
	var save_file: FileAccess = FileAccess.open("user://pathing_graphs/" + path, FileAccess.WRITE)
	save_file.store_line(string)


static func load_flow_field_from_disc(path: String) -> FlowFieldData:
	if FileAccess.file_exists(path):
		var save_file: FileAccess = FileAccess.open(path, FileAccess.READ)
		var json_string: String = save_file.get_line()
		var json: JSON = JSON.new()
		var parse_result: Error = json.parse(json_string)
		if parse_result == OK:
			var dict: Dictionary = json.data
			var flow_field_data: FlowFieldData = FlowFieldData.from_dict(dict)
			return flow_field_data
	return FlowFieldData.new()


func _on_load_button_pressed() -> void:
	if FileAccess.file_exists("user://pathing_graphs/" + save_path.text + ".json"):
		var save_file: FileAccess = FileAccess.open("user://pathing_graphs/" + save_path.text + ".json", FileAccess.READ)
		var json_string: String = save_file.get_line()
		var json: JSON = JSON.new()
		var parse_result: Error = json.parse(json_string)
		if parse_result == OK:
			var dict: Dictionary = json.data
			var flow_field_data: FlowFieldData = FlowFieldData.from_dict(dict)
			flow_field.data = flow_field_data
			for grid: int in flow_field_data.grids:
				create_grid_select_button(grid + 1)
			setup_visualisers_from_flow_field_data(flow_field_data)


func _on_trash_button_pressed() -> void:
	if flow_field:
		flow_field.queue_free()
	for visualiser: FlowNodeVisualiser in visualisers.values():
		visualiser.queue_free()
	visualisers = {}
	for child: Node in $VBoxContainer3.get_children():
		child.queue_free()
	flow_field = FlowField.new()
	flow_field.data = FlowFieldData.new()
	add_child(flow_field)
	flow_field_editor.flow_field = flow_field
	if level:
		level.flow_field = flow_field


func _on_select_all_pressed() -> void:
	selected = []
	for node: FlowNodeVisualiser in flow_field.nodes:
		selected.append(node)


func select_in_grid(grid: int) -> void:
	selected = []
	for node: FlowNodeVisualiser in flow_field.nodes:
		if node.data.grid_id == grid:
			selected.append(node)


func _on_print_ids_pressed() -> void:
	for node: FlowNodeVisualiser in selected:
		print(node.data.node_id)
