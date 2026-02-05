class_name FlowFieldTool
extends Node

@export_group("Basic Function")
@export var zone_list: Array[PackedScene]
@export var zone_holder: Node3D

@export_group("Flow Field Editor")
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
var editing: bool = false
var selected_zone: int = -1
var level: Level
var radius: float = 0
var up_angle: float = 0
var rotate_held: bool = false
var flow_field_data: FlowFieldData


func _ready() -> void:
	var i: int = 0
	for zone: PackedScene in zone_list:
		i += 1
		$VBoxContainer2/OptionButton.add_item("Zone " + str(i))
	$VBoxContainer2/OptionButton.select(0)
	$VBoxContainer2/OptionButton.item_selected.connect(select_zone)
	_on_trash_button_pressed()


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
		#camera_pivot.position += Vector3(x, 0, y) * delta * 30
		#set_cam_position()
		var movement: Vector3 = ((camera_pivot.transform.basis.z * input_vector.y) + (camera_pivot.transform.basis.x * input_vector.x))
		var vec2: Vector2 = Vector2(movement.x, movement.z).normalized()
		camera_pivot.position += Vector3(vec2.x, 0.0, vec2.y) * delta * 30.0


func set_node_colors() -> void:
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


func set_position() -> void:
	for node: FlowNode in selected:
		node.global_position = Vector3(float($Position/x.text), float($Position/y.text), float($Position/z.text))


func offset_position() -> void:
	for node: FlowNode in selected:
		node.global_position += Vector3(float($Position/x.text), float($Position/y.text), float($Position/z.text))


func _on_create_button_pressed() -> void:
	flow_field.create_node()


func _on_generate_grid_button_pressed() -> void:
	flow_field.create_grid(int(x_size_field.text), int(y_size_field.text), float(gap_field.text))
	selected.append_array(flow_field.nodes)
	create_grid_select_button(flow_field.data_file.grids)


func create_grid_select_button(grid: int) -> void:
	var button: Button = Button.new()
	button.text = "Grid " + str(grid)
	button.pressed.connect(select_in_grid.bind(grid))
	$VBoxContainer3.add_child(button)


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
	var grid_num: int = -1
	for node: FlowNode in flow_field.nodes:
		var new_flow_node_data: FlowNodeData = FlowNodeData.new()
		new_flow_node_data.node_id = node.node_id
		new_flow_node_data.grid_id = node.grid_id
		if node.grid_id > grid_num:
			grid_num += 1
		new_flow_node_data.grid_x = node.grid_x
		new_flow_node_data.grid_y = node.grid_y
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
	new_flow_field_data.grids = grid_num
	
	var string: String = JSON.stringify(new_flow_field_data.to_dict())
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
			flow_field.load_from_data(flow_field_data)
			for grid: int in flow_field_data.grids:
				create_grid_select_button(grid + 1)


#func _on_load_button_pressed() -> void:
	#if ResourceLoader.exists(save_path.text + ".res"):
		#print("file exists")
		#var resource: Resource = ResourceLoader.load(save_path.text + ".res", "", ResourceLoader.CACHE_MODE_IGNORE)
		#if resource is FlowFieldData:
			#flow_field.load_from_data(resource)
			#print("loaded some data")
		#else:
			#print("some error loading!")


func _on_trash_button_pressed() -> void:
	if flow_field:
		flow_field.queue_free()
	for child: Node in $VBoxContainer3.get_children():
		child.queue_free()
	flow_field = FlowField.new()
	flow_field_data = FlowFieldData.new()
	flow_field.data_file = flow_field_data
	add_child(flow_field)
	if level:
		level.flow_field = flow_field


func _on_select_all_pressed() -> void:
	selected = []
	for node: FlowNode in flow_field.nodes:
		selected.append(node)


func select_in_grid(grid: int) -> void:
	selected = []
	for node: FlowNode in flow_field.nodes:
		if node.grid_id == grid:
			selected.append(node)
