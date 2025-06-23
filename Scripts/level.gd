class_name Level
extends Node3D

@export var enemy_pool: Array[Enemy]
@export var tower_path: Node
@export var player_spawns: Array[Node3D]
@export var enemy_spawns: Array[EnemySpawner]
@export var enemy_goals: Array[Node3D]
@export var corpses: Node
@export var flow_field: FlowField
@export var cinematic_cam: CinematicCamManager
@export var printer: CardPrinter
@export var shop: ShopStand
@export var obstacle_scenes: Array[PackedScene]
var walls: Dictionary[FlowNode, TowerBase] = {}
var wall_id: int = 0
var tower_base_scene: PackedScene = load("res://Scenes/TowerBase/tower_base.tscn")
var tower_frame_scene: PackedScene = load("res://Scenes/tower_frame.tscn")
var tower_frames: Dictionary[FlowNode, Node3D] = {}
var game_manager: GameManager


func _ready() -> void:
	flow_field.path_updated.connect(enemy_spawns[0].update_path)
	for node: FlowNode in flow_field.nodes:
		if node.buildable:
			var frame: Node3D = tower_frame_scene.instantiate()
			tower_frames[node] = frame
			add_child(frame)
			frame.global_position = node.global_position


func disable_all_tower_frames() -> void:
	for node: FlowNode in tower_frames:
		tower_frames[node].visible = false


func enable_non_path_tower_frames() -> void:
	for node: FlowNode in tower_frames:
		tower_frames[node].visible = true
	disable_path_tower_frames()


func disable_path_tower_frames() -> void:
	for node: FlowNode in tower_frames:
		if node.traversable and !flow_field.traversable_after_blocking_point(node):
			tower_frames[node].visible = false


func set_wall(point: FlowNode, caller_id: int) -> void:
	point.traversable = false
	flow_field.calculate()
	flow_field.path_updated.emit()
	if is_multiplayer_authority():
		spawn_wall(point, wall_id, caller_id)
		wall_id += 1


func remove_wall(point: FlowNode) -> void:
	var wall: TowerBase = walls[point]
	game_manager.connected_players_nodes[wall.owner_id].currency += Data.wall_cost
	game_manager.connected_players_nodes[wall.owner_id].unready_self()
	walls.erase(point)
	wall.queue_free()
	point.traversable = true
	flow_field.calculate()
	flow_field.path_updated.emit()
	enable_non_path_tower_frames()


func spawn_wall(point: FlowNode, name_id: int, caller_id: int) -> void:
	var base: TowerBase = tower_base_scene.instantiate() as TowerBase
	base.game_manager = game_manager
	base.position = point.global_position
	base.name = "Wall" + str(name_id)
	base.owner_id = caller_id
	base.point = point
	walls[point] = base
	tower_path.add_child(base)
	disable_path_tower_frames()


func generate_obstacles() -> void:
	#print(str(multiplayer.get_unique_id()) + " spawning obstacles with seed: " + str(Game.rng.seed))
	var obstacle_count: int = NoiseRandom.randi_in_range(1, 0, 5)
	obstacle_count = 0
#	for index: int in obstacle_count:
#		#var x: int = Game.randi_in_range(10 * index, 1 - a_star_graph_3d.grid_size.x, a_star_graph_3d.grid_size.x - 1)
		#var y: int = Game.randi_in_range(32 * index, 1 - a_star_graph_3d.grid_size.y, a_star_graph_3d.grid_size.y - 1)
#		var chosen_obstacle: int = Game.randi_in_range(4 * index, 0, obstacle_scenes.size() - 1)
#		var obstacle: GridMap = obstacle_scenes[chosen_obstacle].instantiate() as GridMap
#		var orientations: Array[int] = [0, 90, 180, 270]
#		var chosen_orientation: int = Game.randi_in_range(15 * index, 0, orientations.size() - 1)
#		#obstacle.position = Vector3(x, 0, y)
#		obstacle.set_rotation_degrees(Vector3(0, chosen_orientation, 0))
#		add_child(obstacle)
#		for cell: Vector3i in obstacle.get_used_cells():
#			var cell_coord: Vector3 = obstacle.to_global(obstacle.map_to_local(cell))
#			remove_world_tile(round(cell_coord.x), round(cell_coord.z))
#		obstacle.queue_free()


#func cell_coord_to_astar_point(x: int, y: int) -> int:
#	var center_point_x: int = floori(a_star_graph_3d.grid_size.x / 2.0) * a_star_graph_3d.grid_size.y
#	var center_point_y: int = floori(a_star_graph_3d.grid_size.y / 2.0)
#	return (center_point_x + (int(x / 2.0) * a_star_graph_3d.grid_size.y)) + (center_point_y + int(y / 2.0))


#func remove_world_tile(x: int, y: int) -> void:
#	if get_cell_item(Vector3i(x, 0, y)) != 1 or abs(x) >= a_star_graph_3d.grid_size.x or abs(y) >= a_star_graph_3d.grid_size.y:
#		return
#	set_cell_item(Vector3i(x, 0, y), INVALID_CELL_ITEM)
#	var point: int = cell_coord_to_astar_point(x, y)
#	var north_point: int = cell_coord_to_astar_point(x - 1, y)
#	var south_point: int = cell_coord_to_astar_point(x + 1, y)
#	var east_point: int = cell_coord_to_astar_point(x, y + 1)
#	var west_point: int = cell_coord_to_astar_point(x, y - 1)
#	if x % 2 == 0 and y % 2 == 0: #If the tile is on a point on the pathfinding grid
#		a_star_graph_3d.astar.set_point_disabled(point)
#	if x % 2 == 1 and y % 2 == 0: #If the cell breaks a north-south link
#		a_star_graph_3d.astar.disconnect_points(north_point, south_point)
#	if x % 2 == 0 and y % 2 == 1: #If the cell breaks a east-west link
#		a_star_graph_3d.astar.disconnect_points(east_point, west_point)
