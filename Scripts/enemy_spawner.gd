class_name EnemySpawner extends Node3D

signal enemy_spawned()

@export var land_enemy_scene: PackedScene
@export var air_enemy_scene: PackedScene
@export var own_id: int = 0
@export var path: VisualizedPath
@export var type: Data.EnemyType
@export var dest: Node3D
@export var enemy_path: Node

var enemy_died_callback: Callable
var enemy_reached_goal_callback: Callable
var current_wave: Dictionary = {}
var enemy_spawn_timers: Dictionary = {}
var enemies_spawned: Dictionary = {}
var enemies_to_spawn: int = 0
var done_spawning: bool = true
var enemy_id: int = 0


func _process(delta: float) -> void:
	if enemies_to_spawn == 0:
		done_spawning = true
		return
	
	for x: Enemy in enemy_spawn_timers:
		if enemies_spawned[x] == current_wave[x]:
			continue
		
		var enemy_stats: Enemy = x
		enemy_spawn_timers[x] += delta
		
		if enemy_spawn_timers[x] >= enemy_stats.spawn_cooldown:
			if is_multiplayer_authority():
				if type == Data.EnemyType.LAND:
					networked_spawn_land_enemy.rpc(var_to_str(enemy_stats), own_id, enemy_id)
				if type == Data.EnemyType.AIR:
					var radius: float = 10.0
					var random_dir: Vector3 = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
					var random_pos: Vector3 = randf_range(0, radius) * random_dir.normalized()
					networked_spawn_air_enemy.rpc(var_to_str(enemy_stats), random_pos, own_id, enemy_id)
			
			enemy_spawn_timers[x] -= enemy_stats.spawn_cooldown
			enemy_spawned.emit()
			enemy_id += 1
			enemies_spawned[x] += 1
			enemies_to_spawn -= 1


@rpc("reliable", "call_local")
func networked_spawn_land_enemy(enemy_stats: String, id1: int, id2: int) -> void:
	var enemy: EnemyController = land_enemy_scene.instantiate() as EnemyController
	enemy.name = str(id1) + str(id2)
	enemy.stats = str_to_var(enemy_stats)
	enemy.died.connect(enemy_died_callback)
	enemy.reached_goal.connect(enemy_reached_goal_callback)
	enemy.movement_controller.path = path.curve
	enemy.position = global_position
	enemy_path.add_child(enemy)


@rpc("reliable", "call_local")
func networked_spawn_air_enemy(enemy_stats: String, pos: Vector3, id1: int, id2: int) -> void:
	var enemy: EnemyController = air_enemy_scene.instantiate() as EnemyController
	enemy.name = str(id1) + str(id2)
	enemy.position = pos + global_position
	enemy.stats = str_to_var(enemy_stats)
	enemy.died.connect(enemy_died_callback)
	enemy.reached_goal.connect(enemy_reached_goal_callback)
	enemy.movement_controller.goal = dest
	enemy_path.add_child(enemy)


func spawn_wave(value: Dictionary) -> void:
	var relevant_enemies: Dictionary = {}
	var wave: Dictionary = {}
	for index: int in value:
		wave[Data.enemies[index]] = value[index]
	for x: Enemy in wave:
		if x.target_type == type:
			relevant_enemies[x] = wave[x]
	current_wave = relevant_enemies
	enemies_to_spawn = 0
	enemy_spawn_timers = {}
	for x: Enemy in current_wave:
		enemies_to_spawn += current_wave[x]
		enemy_spawn_timers[x] = 0.0
		enemies_spawned[x] = 0
	done_spawning = false
