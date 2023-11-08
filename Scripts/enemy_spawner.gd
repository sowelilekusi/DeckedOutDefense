extends Node3D
class_name EnemySpawner

@export var path : VisualizedPath
@export var type : Data.EnemyType
@export var dest : Node3D

var signal_for_after_enemy_died
var signal_for_after_enemy_reached_goal
signal signal_for_when_enemy_spawns

var current_wave
var enemy_spawn_timers = {}
var enemies_spawned = {}
var enemies_to_spawn := 0
var done_spawning = true

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
			if type == Data.EnemyType.LAND:
				var enemy = land_enemy_scene.instantiate() as EnemyController
				enemy.stats = enemy_stats
				enemy.died.connect(signal_for_after_enemy_died)
				enemy.reached_goal.connect(signal_for_after_enemy_reached_goal)
				path.add_child(enemy)
				enemy_spawn_timers[x] -= enemy_stats.spawn_cooldown
				signal_for_when_enemy_spawns.emit()
			if type == Data.EnemyType.AIR:
				var enemy = air_enemy_scene.instantiate() as AirEnemyController
				enemy.stats = enemy_stats
				enemy.destination = dest
				enemy.died.connect(signal_for_after_enemy_died)
				enemy.reached_goal.connect(signal_for_after_enemy_reached_goal)
				add_child(enemy)
				enemy_spawn_timers[x] -= enemy_stats.spawn_cooldown
				signal_for_when_enemy_spawns.emit()
			enemies_spawned[x] += 1
			enemies_to_spawn -= 1


func spawn_wave(value):
	var relevant_enemies = {}
	for x in value:
		if x.target_type == type:
			relevant_enemies[x] = value[x]
	current_wave = relevant_enemies
	enemies_to_spawn = 0
	enemy_spawn_timers = {}
	for x in current_wave:
		enemies_to_spawn += current_wave[x]
		enemy_spawn_timers[x] = 0.0
		enemies_spawned[x] = 0
	done_spawning = false
