class_name EnemySpawner extends Node3D

signal enemy_spawned()

@export var land_enemy_scene: PackedScene
@export var leap_enemy_scene: PackedScene
@export var air_enemy_scene: PackedScene
@export var path: VisualizedPath
@export var flow_field: FlowField
@export var own_id: int = 0
@export var type: Data.EnemyType
@export var dest: Node3D
@export var enemy_path: Node

var enemy_died_callback: Callable
var enemy_reached_goal_callback: Callable
var current_wave: Array[EnemyCard]
var enemy_types_to_spawn: Dictionary = {}
var enemy_spawn_timers: Dictionary = {}
var enemies_spawned: Dictionary = {}
var enemies_to_spawn: int = 0
var done_spawning: bool = true
var enemy_id: int = 0
var new_path: Path3D
var path_polygon: PackedScene = preload("res://path_polygon.tscn")
var game_manager: GameManager


func _ready() -> void:
	create_path()


func _process(delta: float) -> void:
	if enemies_to_spawn == 0:
		done_spawning = true
		return
	
	for enemy: Enemy in enemy_spawn_timers:
		if enemies_spawned[enemy] == enemy_types_to_spawn[enemy]:
			continue
		
		enemy_spawn_timers[enemy] += delta
		
		if enemy_spawn_timers[enemy] >= enemy.spawn_cooldown:
			if is_multiplayer_authority():
				if type == Data.EnemyType.LAND:
					networked_spawn_land_enemy.rpc(enemy.title, own_id, enemy_id)
				if type == Data.EnemyType.AIR:
					var radius: float = 10.0
					var random_dir: Vector3 = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
					var random_pos: Vector3 = randf_range(0, radius) * random_dir.normalized()
					networked_spawn_air_enemy.rpc(enemy.title, random_pos, own_id, enemy_id)
			
			enemy_spawn_timers[enemy] -= enemy.spawn_cooldown
			enemy_spawned.emit()
			enemy_id += 1
			enemies_spawned[enemy] += 1
			enemies_to_spawn -= 1


#TODO: not sure enemies need all this info over the network
@rpc("reliable", "call_local")
func networked_spawn_land_enemy(enemy_stats: String, id1: int, id2: int) -> void:
	var e_stats: Enemy = null
	for enemy: Enemy in game_manager.level.enemy_pool:
		if enemy.title == enemy_stats:
			e_stats = enemy
	var enemy: EnemyController
	enemy = e_stats.scene.instantiate()
	enemy.corpse_root = game_manager.level.corpses
	enemy.name = str(id1) + str(id2)
	enemy.stats = e_stats
	enemy.died.connect(enemy_died_callback)
	enemy.reached_goal.connect(enemy_reached_goal_callback)
	#enemy.movement_controller.path = path.curve
	#enemy.movement_controller.astar = astar
	enemy.movement_controller.flow_field = flow_field
	enemy.position = global_position
	enemy_path.add_child(enemy)


func create_path() -> void:
	if type != Data.EnemyType.LAND:
		return
	new_path = Path3D.new()
	new_path.curve = Curve3D.new()
	add_child(new_path)
	var polygon: CSGPolygon3D = path_polygon.instantiate()
	new_path.add_child(polygon)
	polygon.mode = CSGPolygon3D.MODE_PATH
	polygon.path_node = new_path.get_path()
	new_path.global_position = Vector3.ZERO
	update_path()



func update_path() -> void:
	if type != Data.EnemyType.LAND:
		return
		new_path.curve.add_point(global_position + Vector3(0, 0.5, 0))
	new_path.curve = Curve3D.new()
	var node: FlowNode = flow_field.get_closest_traversable_point(global_position)
	new_path.curve.add_point(node.global_position + Vector3(0, 0.5, 0))
	while node.best_path:
		node = node.best_path
		new_path.curve.add_point(node.global_position + Vector3(0, 0.5, 0))



@rpc("reliable", "call_local")
func networked_spawn_air_enemy(enemy_stats: String, pos: Vector3, id1: int, id2: int) -> void:
	var e_stats: Enemy = null
	for enemy: Enemy in game_manager.level.enemy_pool:
		if enemy.title == enemy_stats:
			e_stats = enemy
	var enemy: EnemyController
	enemy = e_stats.scene.instantiate()
	enemy.corpse_root = game_manager.level.corpses
	enemy.name = str(id1) + str(id2)
	enemy.position = pos + global_position
	enemy.stats = e_stats
	enemy.died.connect(enemy_died_callback)
	enemy.reached_goal.connect(enemy_reached_goal_callback)
	enemy.movement_controller.goal = dest
	enemy_path.add_child(enemy)


func spawn_wave() -> void:
	enemies_to_spawn = 0
	enemy_spawn_timers = {}
	for card: EnemyCard in current_wave:
		match(card.rarity):
			Data.Rarity.COMMON:
				enemy_types_to_spawn[card.enemy] += card.enemy.common_group
				enemies_to_spawn += card.enemy.common_group
			Data.Rarity.UNCOMMON:
				enemy_types_to_spawn[card.enemy] += card.enemy.uncommon_group
				enemies_to_spawn += card.enemy.uncommon_group
			Data.Rarity.RARE:
				enemy_types_to_spawn[card.enemy] += card.enemy.rare_group
				enemies_to_spawn += card.enemy.rare_group
			Data.Rarity.EPIC:
				enemy_types_to_spawn[card.enemy] += card.enemy.epic_group
				enemies_to_spawn += card.enemy.epic_group
			Data.Rarity.LEGENDARY:
				enemy_types_to_spawn[card.enemy] += card.enemy.legendary_group
				enemies_to_spawn += card.enemy.legendary_group
		enemy_spawn_timers[card.enemy] = 0.0
		enemies_spawned[card.enemy] = 0
	current_wave = []
	done_spawning = false


func add_card(new_card: EnemyCard) -> void:
	current_wave.append(new_card)
	enemy_types_to_spawn[new_card.enemy] = 0
