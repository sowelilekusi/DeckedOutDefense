extends Node3D
class_name EnemySpawner

@export var own_id : int = 0
@export var path : VisualizedPath
@export var type : Data.EnemyType
@export var dest : Node3D
@export var enemy_path : Node

var signal_for_after_enemy_died
var signal_for_after_enemy_reached_goal
signal signal_for_when_enemy_spawns

var current_wave
var enemy_spawn_timers = {}
var enemies_spawned = {}
var enemies_to_spawn := 0
var done_spawning = true
var enemy_id = 0

@export var land_enemy_scene : PackedScene
@export var air_enemy_scene : PackedScene


func _process(delta: float) -> void:
	if enemies_to_spawn == 0:
		done_spawning = true
		return
	
	for x in enemy_spawn_timers:
		if enemies_spawned[x] == current_wave[x]:
			continue
		
		var enemy_stats = x
		enemy_spawn_timers[x] += delta
		
		if enemy_spawn_timers[x] >= enemy_stats.spawn_cooldown:
			if is_multiplayer_authority():
				if type == Data.EnemyType.LAND:
					networked_spawn_land_enemy.rpc(var_to_str(enemy_stats), own_id, enemy_id)
				if type == Data.EnemyType.AIR:
					var radius = 10.0
					var random_dir = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
					var random_pos = randf_range(0, radius) * random_dir.normalized()
					networked_spawn_air_enemy.rpc(var_to_str(enemy_stats), random_pos, own_id, enemy_id)
			
			enemy_spawn_timers[x] -= enemy_stats.spawn_cooldown
			signal_for_when_enemy_spawns.emit()
			enemy_id += 1
			enemies_spawned[x] += 1
			enemies_to_spawn -= 1


@rpc("reliable", "call_local")
func networked_spawn_land_enemy(enemy_stats, id1, id2):
	var enemy = land_enemy_scene.instantiate() as EnemyController
	enemy.name = str(id1) + str(id2)
	enemy.stats = str_to_var(enemy_stats)
	enemy.died.connect(signal_for_after_enemy_died)
	enemy.reached_goal.connect(signal_for_after_enemy_reached_goal)
	enemy.movement_controller.path = path.curve
	enemy.position = global_position
	enemy_path.add_child(enemy)


@rpc("reliable", "call_local")
func networked_spawn_air_enemy(enemy_stats, pos, id1, id2):
	var enemy = air_enemy_scene.instantiate() as EnemyController
	enemy.name = str(id1) + str(id2)
	enemy.position = pos + global_position
	enemy.stats = str_to_var(enemy_stats)
	enemy.died.connect(signal_for_after_enemy_died)
	enemy.reached_goal.connect(signal_for_after_enemy_reached_goal)
	enemy.movement_controller.goal = dest
	enemy_path.add_child(enemy)


func spawn_wave(value):
	var relevant_enemies = {}
	var wave = {}
	for index in value:
		wave[Data.enemies[index]] = value[index]
	for x in wave:
		if x.target_type == type:
			relevant_enemies[x] = wave[x]
	current_wave = relevant_enemies
	enemies_to_spawn = 0
	enemy_spawn_timers = {}
	for x in current_wave:
		enemies_to_spawn += current_wave[x]
		enemy_spawn_timers[x] = 0.0
		enemies_spawned[x] = 0
	done_spawning = false
