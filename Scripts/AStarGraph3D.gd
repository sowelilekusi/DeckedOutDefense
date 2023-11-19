extends Node3D
class_name AStarGraph3D

@export var grid_size := Vector2i(21, 13)
@export var point_gap := 1.2
var non_build_locations = []
var astar := AStar3D.new()

#TODO generalize this better
@export var start : Node3D
@export var end : Node3D
@export var spawner : EnemySpawner
@export var visualized_path : VisualizedPath
@export var tower_path : Node
var tower_base_scene = load("res://Scenes/tower_base.tscn")
var tower_frame_scene = load("res://Scenes/tower_frame.tscn")
var tower_bases = []
var wall_id = 0


func toggle_point(point_id):
	networked_toggle_point.rpc(point_id)


func point_is_build_location(point_id):
	return !non_build_locations.has(point_id)


func test_path_if_point_toggled(point_id) -> bool:
	if astar.is_point_disabled(point_id):
		astar.set_point_disabled(point_id, false)
	else:
		astar.set_point_disabled(point_id, true)
	var result = find_path()
	if astar.is_point_disabled(point_id):
		astar.set_point_disabled(point_id, false)
	else:
		astar.set_point_disabled(point_id, true)
	return result


@rpc("reliable", "any_peer", "call_local")
func networked_toggle_point(point_id):
	if astar.is_point_disabled(point_id):
		astar.set_point_disabled(point_id, false)
	else:
		astar.set_point_disabled(point_id, true)
	find_path()
	if is_multiplayer_authority():
		networked_spawn_wall.rpc(astar.get_point_position(point_id), wall_id)
		wall_id += 1


@rpc("reliable", "call_local")
func networked_spawn_wall(pos : Vector3, name_id : int):
	var base = tower_base_scene.instantiate()
	base.position = pos
	base.name = "Wall" + str(name_id)
	tower_bases.append(base)
	tower_path.add_child(base)


func build_random_maze(block_limit):
	var untested_point_ids = []
	for index in (grid_size.x * grid_size.y):
		untested_point_ids.append(index)
	if block_limit <= 0 or block_limit > untested_point_ids.size():
		block_limit = untested_point_ids.size()
	for index in block_limit:
		var random_point = untested_point_ids.pick_random()
		untested_point_ids.erase(random_point)
		if test_path_if_point_toggled(random_point):
			networked_toggle_point.rpc(random_point)


func place_random_towers(tower_limit):
	var untowered_bases = tower_bases.duplicate()
	if tower_limit <= 0 or tower_limit > untowered_bases.size():
		tower_limit = untowered_bases.size()
	for index in tower_limit:
		var random_base = untowered_bases.pick_random() as TowerBase
		untowered_bases.erase(random_base)
		random_base.add_card(Data.cards.pick_random())


func find_path() -> bool:
	var path = astar.get_point_path(astar.get_point_count() - 2, astar.get_point_count() - 1)
	if !path.is_empty():
		var curve = Curve3D.new()
		for point in path:
			curve.add_point(point)
		spawner.path.curve = curve
		spawner.path.spawn_visualizer_points()
		return true
	return false


func make_grid():
	for x in grid_size.x:
		for y in grid_size.y:
			var point_position = Vector3((x - floori(grid_size.x / 2)) * point_gap, 0.5, (y - floori(grid_size.y / 2)) * point_gap)
			astar.add_point(int(x * grid_size.y + y), point_position)
			var frame = tower_frame_scene.instantiate()
			frame.position = point_position
			add_child(frame)
	
	for x in grid_size.x:
		for y in grid_size.y:
			var point_id = grid_size.y * x + y
			if x > 0:
				var north_point_id = grid_size.y * (x - 1) + y
				astar.connect_points(point_id, north_point_id, false)
			if x < grid_size.x - 1:
				var south_point_id = grid_size.y * (x + 1) + y
				astar.connect_points(point_id, south_point_id, false)
			if y > 0:
				var east_point_id = grid_size.y * x + (y - 1)
				astar.connect_points(point_id, east_point_id, false)
			if y < grid_size.y - 1:
				var west_point_id = grid_size.y * x + (y + 1)
				astar.connect_points(point_id, west_point_id, false)
	
	non_build_locations.append(astar.get_point_count())
	astar.add_point(astar.get_point_count(), start.global_position)
	for x in grid_size.y:
		astar.connect_points(int(astar.get_point_count() - 1), x)
	non_build_locations.append(astar.get_point_count())
	astar.add_point(astar.get_point_count(), end.global_position)
	for x in grid_size.y:
		astar.connect_points(astar.get_point_count() - 1, int(grid_size.y * (grid_size.x - 1) + x))
