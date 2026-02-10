class_name Level
extends Node3D

@export var enemy_pool: Array[Enemy]
@export var tower_path: Node
@export var player_spawns: Array[Node3D]
@export var enemy_spawns: Array[EnemySpawner]
@export var enemy_goals: Array[Node3D]
@export var corpses: Node
@export var printer: CardPrinter
@export var shop: ShopStand
@export var obstacles: Array[PackedScene]

var walls: Dictionary[FlowNodeData, TowerBase] = {}
var wall_id: int = 0
var tower_base_scene: PackedScene = load("res://Scenes/TowerBase/tower_base.tscn")
var tower_frame_scene: PackedScene = load("res://Scenes/tower_frame.tscn")
var tower_frames: Dictionary[FlowNodeData, Node3D] = {}
var game_manager: GameManager
var flow_field: FlowField


func load_flow_field() -> void:
	for spawn: EnemySpawner in enemy_spawns:
		flow_field.path_updated.connect(spawn.update_path)
	
	for node: FlowNodeData in flow_field.data.nodes:
		if node.buildable:
			var frame: Node3D = tower_frame_scene.instantiate()
			tower_frames[node] = frame
			add_child(frame)
			frame.position = node.position


func disable_all_tower_frames() -> void:
	for node: FlowNodeData in tower_frames:
		tower_frames[node].visible = false


func enable_non_path_tower_frames() -> void:
	for node: FlowNodeData in tower_frames:
		tower_frames[node].visible = true
	disable_path_tower_frames()


func disable_path_tower_frames() -> void:
	for node: FlowNodeData in tower_frames:
		if node.traversable and !flow_field.traversable_after_blocking_point(node):
			tower_frames[node].visible = false


func set_wall(node_id: int, caller_id: int) -> void:
	var point: FlowNodeData
	for node: FlowNodeData in flow_field.data.nodes:
		if node.node_id == node_id:
			point = node
	point.traversable = false
	flow_field.calculate()
	flow_field.path_updated.emit()
	spawn_wall(point, wall_id, caller_id)
	wall_id += 1


func remove_wall(point: FlowNodeData) -> void:
	var wall: TowerBase = walls[point]
	#game_manager.connected_players_nodes[wall.owner_id].currency += Data.wall_cost
	game_manager.connected_players_nodes[wall.owner_id].unready_self()
	walls.erase(point)
	wall.queue_free()
	point.traversable = true
	flow_field.calculate()
	flow_field.path_updated.emit()
	enable_non_path_tower_frames()


func spawn_wall(point: FlowNodeData, name_id: int, caller_id: int) -> void:
	var base: TowerBase = tower_base_scene.instantiate() as TowerBase
	base.game_manager = game_manager
	base.position = point.position
	base.name = "Wall" + str(name_id)
	base.owner_id = caller_id
	base.point = point
	walls[point] = base
	tower_path.add_child(base)
	disable_path_tower_frames()


func generate_obstacles(ids: Array[int]) -> void:
	var points: Array[FlowNodeData] = []
	for node: FlowNodeData in flow_field.data.nodes:
		if ids.has(node.node_id):
			points.append(node)
	for node: FlowNodeData in points:
		var obstacle: Node3D = obstacles[0].instantiate()
		obstacle.position = node.position
		flow_field.toggle_buildable(node)
		if node.traversable:
			flow_field.toggle_traversable(node)
		add_child(obstacle)
