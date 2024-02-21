class_name Level extends GridMap

@export var enemy_pool: Array[Enemy]
@export var player_spawns: Array[Node3D]
@export var enemy_spawns: Array[Node3D]
@export var enemy_goals: Array[Node3D]
@export var corpses: Node3D
@export var a_star_graph_3d: AStarGraph3D
@export var cinematic_cam: CinematicCamManager
@export var printer: CardPrinter
@export var shop: ShopStand
@export var obstacle_scenes: Array[PackedScene]


func generate_obstacles() -> void:
	var obstacle_count: int = randi_range(0, 5)
	for index: int in obstacle_count:
		var x: int = randi_range(0, a_star_graph_3d.grid_size.x - 1)
		var y: int = randi_range(0, a_star_graph_3d.grid_size.y - 1)
		var point_id: int = int(x * a_star_graph_3d.grid_size.y + y)
		var chosen_obstacle: int = randi_range(0, obstacle_scenes.size() - 1)
		var obstacle: GridMap = obstacle_scenes[chosen_obstacle].instantiate() as GridMap
		var orientations: Array[int] = [0, 90, 180, 270]
		var chosen_orientation: int = orientations.pick_random()
		obstacle.position = a_star_graph_3d.astar.get_point_position(point_id)
		obstacle.set_rotation_degrees(Vector3(0, chosen_orientation, 0))
		add_child(obstacle)
		for cell: Vector3i in obstacle.get_used_cells():
			var cell_pos: Vector3 = obstacle.to_global(obstacle.map_to_local(cell))
			var map_coord: Vector3i = Vector3i(round(cell_pos.x), 0, round(cell_pos.z))
			#print("cell_pos: " + str(cell_pos) + "cell.z" + str(cell_pos.z) + ", map_coord: " + str(map_coord))
			var closest_point: int = a_star_graph_3d.astar.get_closest_point(cell_pos, true)
			var closest_point_pos: Vector3 = a_star_graph_3d.astar.get_point_position(closest_point)
			if closest_point_pos.distance_to(Vector3(cell_pos.x, closest_point_pos.y, cell_pos.z)) <= 0.5:
				a_star_graph_3d.astar.set_point_disabled(closest_point)
			if get_cell_item(map_coord) == 1:
				set_cell_item(map_coord, INVALID_CELL_ITEM)
		obstacle.queue_free()
