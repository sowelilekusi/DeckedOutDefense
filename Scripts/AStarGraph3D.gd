extends Node3D
class_name AStarGraph3D

@export var grid_size := Vector2i(15, 7)
@export var point_gap := 2.0
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
var tower_base_ids = {}
var tower_frames = []
var wall_id = 0


func toggle_point(point_id, caller_id):
	networked_toggle_point.rpc(point_id, caller_id)


func remove_wall(wall : TowerBase):
	networked_remove_wall.rpc(wall.point_id)
	toggle_point(wall.point_id, multiplayer.get_unique_id())


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
func networked_toggle_point(point_id, caller_id):
	if astar.is_point_disabled(point_id):
		astar.set_point_disabled(point_id, false)
	else:
		astar.set_point_disabled(point_id, true)
	find_path()
	enable_non_path_tower_frames()
	if is_multiplayer_authority() and astar.is_point_disabled(point_id):
		networked_spawn_wall.rpc(astar.get_point_position(point_id), wall_id, caller_id)
		wall_id += 1


func get_north_point(point_id) -> int:
	var x = point_id / grid_size.y
	var y = point_id % grid_size.y
	if x - 1 >= 0: #if the north point id could possibly exist as a neighbor
		return (x - 1) * grid_size.y + y
	return -1


func get_south_point(point_id) -> int:
	var x = point_id / grid_size.y
	var y = point_id % grid_size.y
	if x + 1 <= grid_size.x - 1: #if the south point id could possibly exist as a neighbor
		return (x + 1) * grid_size.y + y
	return -1


func get_west_point(point_id) -> int:
	var x = point_id / grid_size.y
	var y = point_id % grid_size.y
	if y + 1 <= grid_size.y - 1: #if the east point id could possibly exist as a neighbor
		return x * grid_size.y + y + 1
	return -1


func get_east_point(point_id) -> int:
	var x = point_id / grid_size.y
	var y = point_id % grid_size.y
	if y - 1 >= 0: #if the west point id could possibly exist as a neighbor
		return x * grid_size.y + y - 1
	return -1


func count_valid_neighbours(point_id) -> int:
	if !point_id:
		return 0
	var valid_neighbours = 0
	var north_point = get_north_point(point_id)
	var south_point = get_south_point(point_id)
	var east_point = get_east_point(point_id)
	var west_point = get_west_point(point_id)
	
	if north_point and !astar.is_point_disabled(north_point):
		valid_neighbours += 1
	else: #add the spawn point which is always valid
		valid_neighbours += 1
	
	if south_point and !astar.is_point_disabled(south_point):
		valid_neighbours += 1
	else: #add the goal point which is always valid
		valid_neighbours += 1
	
	if east_point and !astar.is_point_disabled(east_point):
		valid_neighbours += 1
	
	if west_point and !astar.is_point_disabled(west_point):
		valid_neighbours += 1
	return valid_neighbours


func disable_all_tower_frames():
	for frame in tower_frames:
		frame.set_visible(false)


func enable_non_path_tower_frames():
	for frame in tower_frames:
		frame.set_visible(true)
	disable_path_tower_frames()


func disable_path_tower_frames():
	for id in astar.get_id_path(astar.get_point_count() - 2, astar.get_point_count() - 1):
		if id < (grid_size.x * grid_size.y) and !test_path_if_point_toggled(id):
			tower_frames[id].set_visible(false)


@rpc("reliable", "call_local")
func networked_spawn_wall(pos : Vector3, name_id : int, caller_id : int):
	var base = tower_base_scene.instantiate() as TowerBase
	base.position = pos
	base.name = "Wall" + str(name_id)
	base.owner_id = caller_id
	var point_id = astar.get_closest_point(pos, true)
	base.point_id = point_id
	tower_base_ids[point_id] = base
	tower_bases.append(base)
	tower_path.add_child(base)
	var north_point = get_north_point(point_id)
	var south_point = get_south_point(point_id)
	var east_point = get_east_point(point_id)
	var west_point = get_west_point(point_id)
	if north_point >= 0 and astar.is_point_disabled(north_point):
		base.set_north_wall(true)
		tower_base_ids[north_point].set_south_wall(true)
	if south_point >= 0 and astar.is_point_disabled(south_point):
		base.set_south_wall(true)
		tower_base_ids[south_point].set_north_wall(true)
	if east_point >= 0 and astar.is_point_disabled(east_point):
		base.set_east_wall(true)
		tower_base_ids[east_point].set_west_wall(true)
	if west_point >= 0 and astar.is_point_disabled(west_point):
		base.set_west_wall(true)
		tower_base_ids[west_point].set_east_wall(true)


@rpc("reliable", "call_local", "any_peer")
func networked_remove_wall(new_wall_id: int):
	var wall = tower_base_ids[new_wall_id]
	Game.connected_players_nodes[wall.owner_id].currency += Data.wall_cost
	tower_bases.erase(wall)
	tower_base_ids.erase(new_wall_id)
	wall.queue_free()
	var north_point = get_north_point(new_wall_id)
	var south_point = get_south_point(new_wall_id)
	var east_point = get_east_point(new_wall_id)
	var west_point = get_west_point(new_wall_id)
	if north_point >= 0 and astar.is_point_disabled(north_point):
		tower_base_ids[north_point].set_south_wall(false)
	if south_point >= 0 and astar.is_point_disabled(south_point):
		tower_base_ids[south_point].set_north_wall(false)
	if east_point >= 0 and astar.is_point_disabled(east_point):
		tower_base_ids[east_point].set_west_wall(false)
	if west_point >= 0 and astar.is_point_disabled(west_point):
		tower_base_ids[west_point].set_east_wall(false)


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
			networked_toggle_point.rpc(random_point, multiplayer.get_unique_id())


func place_random_towers(tower_limit):
	var untowered_bases = tower_bases.duplicate()
	if tower_limit <= 0 or tower_limit > untowered_bases.size():
		tower_limit = untowered_bases.size()
	for index in tower_limit:
		var random_base = untowered_bases.pick_random() as TowerBase
		untowered_bases.erase(random_base)
		random_base.add_card(Data.cards.pick_random(), multiplayer.get_unique_id())


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
			tower_frames.append(frame)
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
